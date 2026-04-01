import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../poes_arkanoid_game.dart';
import '../config/game_config.dart' as config;

/// The player-controlled paddle.
///
/// Moves via lerp toward the touch/pointer target position.
/// Supports size power-ups (extend / shrink) with timed expiry.
class Paddle extends SpriteComponent
    with HasGameReference<PoesArkanoidGame> {
  Paddle()
      : super(
          anchor: Anchor.center,
          priority: 5,
        );

  late double baseWidth;
  late double _targetX;
  late double _targetY;

  // Power-up state
  bool isExtended = false;
  bool isShrunk = false;
  double _powerUpTimer = 0;

  // ------------------------------------------------------------------
  // Lifecycle
  // ------------------------------------------------------------------
  @override
  Future<void> onLoad() async {
    sprite = Sprite(game.images.fromCache('items/paddle_main.png'));

    baseWidth = game.size.x * config.paddleWidthFraction;
    final h = game.size.y * config.paddleHeightFraction;
    size = Vector2(baseWidth, h);

    setStartingPosition();

    add(RectangleHitbox());
  }

  // ------------------------------------------------------------------
  // Positioning
  // ------------------------------------------------------------------
  void setStartingPosition() {
    position = Vector2(
      game.size.x / 2,
      game.size.y * (1 - config.paddleBottomMarginFraction),
    );
    _targetX = position.x;
    _targetY = position.y;
  }

  /// Called from game's pan/drag handler.
  void moveTo(Vector2 pointerPosition) {
    _targetX = pointerPosition.x;
    _targetY = pointerPosition.y - game.size.y * config.paddleHoverOffset;
  }

  // ------------------------------------------------------------------
  // Update
  // ------------------------------------------------------------------
  @override
  void update(double dt) {
    super.update(dt);

    // Check power-up expiry
    if (_powerUpTimer > 0) {
      _powerUpTimer -= dt;
      if (_powerUpTimer <= 0) {
        resetSize();
      }
    }

    // Lerp toward target
    position.x += (_targetX - position.x) * config.paddleLerp;
    position.y += (_targetY - position.y) * config.paddleLerp;

    // Clamp X
    final halfW = size.x / 2;
    position.x = position.x.clamp(halfW, game.size.x - halfW);

    // Clamp Y (don't go above 45% of screen)
    final minY = game.size.y * 0.45;
    final maxY = game.size.y * (1 - config.paddleBottomMarginFraction);
    position.y = position.y.clamp(minY, maxY);
  }

  // ------------------------------------------------------------------
  // Power-up size changes
  // ------------------------------------------------------------------
  void extend() {
    size.x = baseWidth * config.paddleExtendMultiplier;
    isExtended = true;
    isShrunk = false;
    _powerUpTimer = config.powerUpDuration;
  }

  void shrink() {
    size.x = baseWidth * config.paddleShrinkMultiplier;
    isShrunk = true;
    isExtended = false;
    _powerUpTimer = config.powerUpDuration;
  }

  void resetSize() {
    size.x = baseWidth;
    isExtended = false;
    isShrunk = false;
    _powerUpTimer = 0;
  }
}
