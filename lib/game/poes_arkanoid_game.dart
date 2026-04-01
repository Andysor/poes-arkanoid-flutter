import 'package:flame/events.dart';
import 'package:flame/game.dart';

import 'components/ball.dart';
import 'components/ball_trail.dart';
import 'components/paddle.dart';
import 'components/level.dart';
import 'components/power_up.dart';
import 'managers/audio_manager.dart';
import 'config/game_config.dart' as config;
import 'config/asset_paths.dart';

/// Input / game-state modes matching the web version.
enum InputMode { waitForStart, playing, gameOver }

class PoesArkanoidGame extends FlameGame
    with PanDetector, TapCallbacks, HasCollisionDetection {
  PoesArkanoidGame({
    required this.playerName,
    required this.selectedCharacter,
  });

  // ------------------------------------------------------------------
  // Player info
  // ------------------------------------------------------------------
  final String playerName;
  final String selectedCharacter;

  // ------------------------------------------------------------------
  // Game state
  // ------------------------------------------------------------------
  int score = 0;
  int lives = config.initialLives;
  int level = 1;
  InputMode inputMode = InputMode.waitForStart;
  bool brannasActive = false;
  double brannasEndTime = 0;

  // ------------------------------------------------------------------
  // Components (set during onLoad)
  // ------------------------------------------------------------------
  late Paddle paddle;
  late BallTrail ballTrail;
  late Level currentLevel;
  late AudioManager audioManager;

  /// All active balls (main + extras). Main ball is always first.
  final List<Ball> balls = [];
  Ball get mainBall => balls.first;

  final List<PowerUpItem> activePowerUps = [];

  // ------------------------------------------------------------------
  // Timing
  // ------------------------------------------------------------------
  double _gameTime = 0;
  double _speedRampAccumulator = 0;

  // ------------------------------------------------------------------
  // Lifecycle
  // ------------------------------------------------------------------
  @override
  Future<void> onLoad() async {
    await super.onLoad();

    audioManager = AudioManager();

    // Load images and audio in parallel
    await Future.wait([
      images.loadAll(AssetPaths.allImages),
      audioManager.preloadAll(),
    ]);

    // Add components
    currentLevel = Level(levelNumber: level);
    add(currentLevel);

    paddle = Paddle();
    add(paddle);

    ballTrail = BallTrail();
    add(ballTrail);

    final ball = Ball();
    balls.add(ball);
    add(ball);

    ball.placeOnPaddle(paddle);
  }

  @override
  void onRemove() {
    audioManager.dispose();
    super.onRemove();
  }

  // ------------------------------------------------------------------
  // Game loop
  // ------------------------------------------------------------------
  @override
  void update(double dt) {
    super.update(dt);

    if (inputMode != InputMode.playing) return;

    _gameTime += dt;

    // Speed ramp on accumulator
    _speedRampAccumulator += dt;
    if (_speedRampAccumulator >= config.speedIncreaseInterval) {
      _speedRampAccumulator -= config.speedIncreaseInterval;
      for (final b in balls) {
        b.increaseSpeed(level);
      }
    }

    // Check brannas expiration
    if (brannasActive && _gameTime > brannasEndTime) {
      brannasActive = false;
    }

    // Clean up unmounted power-ups
    activePowerUps.removeWhere((pu) => !pu.isMounted);

    // Check level complete
    if (currentLevel.isComplete) {
      _nextLevel();
    }
  }

  // ------------------------------------------------------------------
  // Input handling
  // ------------------------------------------------------------------
  @override
  void onPanUpdate(DragUpdateInfo info) {
    paddle.moveTo(info.eventPosition.widget);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (inputMode == InputMode.waitForStart) {
      _startBall();
    }
  }

  // ------------------------------------------------------------------
  // Game actions
  // ------------------------------------------------------------------
  void _startBall() {
    inputMode = InputMode.playing;
    mainBall.launch();
  }

  void addScore(int points) {
    score += points;
  }

  void loseLife() {
    if (inputMode == InputMode.gameOver) return;
    lives--;
    _removeAllExtraBalls();
    ballTrail.clear();
    _clearActivePowerUps();
    brannasActive = false;

    if (lives <= 0) {
      _gameOver();
      return;
    }

    audioManager.play('lifeloss');
    mainBall.reset();
    mainBall.placeOnPaddle(paddle);
    paddle.resetSize();
    inputMode = InputMode.waitForStart;
  }

  void _nextLevel() {
    if (level >= config.maxLevel) {
      _gameOver();
      return;
    }
    level++;
    _removeAllExtraBalls();
    ballTrail.clear();
    _clearActivePowerUps();
    brannasActive = false;

    currentLevel.removeFromParent();
    currentLevel = Level(levelNumber: level);
    add(currentLevel);

    mainBall.reset();
    mainBall.placeOnPaddle(paddle);
    inputMode = InputMode.waitForStart;
  }

  void _gameOver() {
    inputMode = InputMode.gameOver;
    _removeAllExtraBalls();
    ballTrail.clear();
    _clearActivePowerUps();
    mainBall.reset();
    audioManager.play('game_over');
    pauseEngine();
    overlays.add('gameOver');
  }

  void activateBrannas() {
    brannasActive = true;
    brannasEndTime = _gameTime + config.brannasDuration;
  }

  bool get isBrannasActive => brannasActive && _gameTime <= brannasEndTime;

  /// Called by [Ball] when it falls below the screen.
  void onBallLost(Ball lostBall) {
    if (lostBall.isExtra) {
      lostBall.removeFromParent();
      balls.remove(lostBall);
    } else {
      loseLife();
    }
  }

  /// Spawn a falling power-up item at the given position.
  void spawnPowerUp(String type, Vector2 position) {
    final pu = PowerUpItem(type: type, startPosition: position);
    activePowerUps.add(pu);
    add(pu);
  }

  /// Handle collecting a power-up (paddle collision).
  void collectPowerUp(PowerUpItem powerUp) {
    powerUp.removeFromParent();
    activePowerUps.remove(powerUp);

    final puType = powerUp.type.toLowerCase();

    switch (puType) {
      case 'brannas':
        activateBrannas();
        addScore(config.pointsBrannas);
      case 'extra_life':
        lives++;
      case 'skull':
        loseLife();
      case 'large_paddle':
      case 'powerup_largepaddle':
        paddle.extend();
      case 'small_paddle':
      case 'powerup_smallpaddle':
        paddle.shrink();
      case 'extraball':
        _spawnExtraBall();
        addScore(config.pointsExtraBall);
      case 'coin_gold':
        addScore(config.pointsGoldCoin);
      case 'coin_silver':
        addScore(config.pointsSilverCoin);
    }

    audioManager.playForPowerUp(puType);
  }

  // ------------------------------------------------------------------
  // Helpers
  // ------------------------------------------------------------------
  void _spawnExtraBall() {
    final extra = Ball(isExtra: true);
    extra.position = mainBall.position.clone();
    extra.launch(angleOffset: 0.785);
    extra.setDuration(config.powerUpDuration);
    balls.add(extra);
    add(extra);
  }

  void _removeAllExtraBalls() {
    for (final b in balls.where((b) => b.isExtra).toList()) {
      b.removeFromParent();
      balls.remove(b);
    }
  }

  void _clearActivePowerUps() {
    for (final pu in activePowerUps) {
      pu.removeFromParent();
    }
    activePowerUps.clear();
  }
}
