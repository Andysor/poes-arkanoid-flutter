import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/painting.dart';

import 'components/ball.dart';
import 'components/paddle.dart';
import 'components/brick.dart';
import 'components/level.dart';
import 'components/power_up.dart';
import 'components/ball_trail.dart';
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
  late Ball ball;
  late Level currentLevel;
  late AudioManager audioManager;

  final List<PowerUpItem> activePowerUps = [];

  // ------------------------------------------------------------------
  // Lifecycle
  // ------------------------------------------------------------------
  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Pre-load all images
    await images.loadAll(AssetPaths.allImages);

    // Audio
    audioManager = AudioManager();
    // TODO: preload audio files

    // Add level (bricks + background)
    currentLevel = Level(levelNumber: level);
    await add(currentLevel);

    // Add paddle
    paddle = Paddle();
    await add(paddle);

    // Add ball
    ball = Ball();
    await add(ball);

    // Place ball on paddle
    ball.placeOnPaddle(paddle);
  }

  // ------------------------------------------------------------------
  // Game loop
  // ------------------------------------------------------------------
  @override
  void update(double dt) {
    super.update(dt);

    if (inputMode != InputMode.playing) return;

    // Check brannas expiration
    if (brannasActive && _gameTime > brannasEndTime) {
      brannasActive = false;
    }

    // Update active power-ups (falling items)
    for (final pu in List.of(activePowerUps)) {
      if (!pu.isMounted) {
        activePowerUps.remove(pu);
      }
    }

    // Check level complete
    if (currentLevel.isComplete) {
      _nextLevel();
    }
  }

  double _gameTime = 0;

  @override
  void onMount() {
    super.onMount();
    _gameTime = 0;
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
    ball.launch();
  }

  void addScore(int points) {
    score += points;
  }

  void loseLife() {
    lives--;
    if (lives <= 0) {
      _gameOver();
      return;
    }

    audioManager.play('lifeloss');

    // Reset ball onto paddle
    ball.reset();
    ball.placeOnPaddle(paddle);
    inputMode = InputMode.waitForStart;
  }

  void _nextLevel() {
    level++;
    // Remove old level, load new one
    currentLevel.removeFromParent();
    currentLevel = Level(levelNumber: level);
    add(currentLevel);

    // Reset ball
    ball.reset();
    ball.placeOnPaddle(paddle);
    inputMode = InputMode.waitForStart;
  }

  void _gameOver() {
    inputMode = InputMode.gameOver;
    audioManager.play('game_over');
    overlays.add('gameOver');
  }

  void activateBrannas() {
    brannasActive = true;
    brannasEndTime = _gameTime + config.brannasDuration;
  }

  bool get isBrannasActive => brannasActive && _gameTime <= brannasEndTime;

  /// Called by [Ball] when it falls below the screen.
  void onBallLost(Ball lostBall) {
    if (lostBall.isExtraBall) {
      lostBall.removeFromParent();
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

  void _spawnExtraBall() {
    final extra = Ball(isExtra: true);
    extra.position = ball.position.clone();
    extra.launch(angleOffset: 0.785); // 45 degrees offset
    add(extra);
  }
}
