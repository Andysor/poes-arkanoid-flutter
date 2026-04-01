import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../poes_arkanoid_game.dart';
import '../config/game_config.dart' as config;
import 'paddle.dart';
import 'brick.dart';
import 'power_up.dart';

/// The ball component.
///
/// Handles movement, wall/paddle/brick collisions, speed ramping,
/// and the brannas "pass through" effect.
class Ball extends SpriteComponent
    with HasGameReference<PoesArkanoidGame>, CollisionCallbacks {
  Ball({this.isExtra = false})
      : super(
          anchor: Anchor.center,
          priority: 10,
        );

  final bool isExtra;

  /// Velocity in pixels/second.
  Vector2 velocity = Vector2.zero();

  /// Current speed magnitude.
  double speed = config.baseInitialSpeed;

  /// Whether the ball is actively moving.
  bool isMoving = false;

  /// Whether this is an extra ball (from power-up).
  bool get isExtraBall => isExtra;

  /// Duration tracking for extra balls (seconds).
  double _duration = 0;
  double _elapsed = 0;

  final _rng = Random();

  // ------------------------------------------------------------------
  // Lifecycle
  // ------------------------------------------------------------------
  @override
  Future<void> onLoad() async {
    final imageName = isExtra
        ? 'items/extra_ball.png'
        : 'items/ball.png';
    sprite = Sprite(game.images.fromCache(imageName));

    final radius = game.size.x * config.ballRadiusFraction;
    size = Vector2.all(radius * 2);

    add(CircleHitbox());
  }

  // ------------------------------------------------------------------
  // Placement helpers
  // ------------------------------------------------------------------
  void placeOnPaddle(Paddle paddle) {
    isMoving = false;
    velocity = Vector2.zero();
    position = Vector2(
      paddle.position.x,
      paddle.position.y - paddle.size.y / 2 - size.y / 2 - 2,
    );
  }

  // ------------------------------------------------------------------
  // Launch
  // ------------------------------------------------------------------
  void launch({double angleOffset = 0}) {
    if (isMoving) return;

    speed = config.baseInitialSpeed;
    final angle = -pi / 4 + angleOffset; // default 45 degrees upward
    velocity = Vector2(cos(angle), sin(angle)) * speed;
    isMoving = true;

    _addRandomFactor();
  }

  // ------------------------------------------------------------------
  // Update
  // ------------------------------------------------------------------
  @override
  void update(double dt) {
    super.update(dt);

    if (!isMoving) {
      // Follow paddle when idle
      if (!isExtra) {
        final paddle = game.paddle;
        position = Vector2(
          paddle.position.x,
          paddle.position.y - paddle.size.y / 2 - size.y / 2,
        );
      }
      return;
    }

    // Move
    position += velocity * dt;

    // Trail particles
    game.ballTrail.addParticle(position, size.x / 2);

    // Track extra ball lifetime
    if (isExtra && _duration > 0) {
      _elapsed += dt;
      if (_elapsed >= _duration) {
        game.onBallLost(this);
        return;
      }
    }

    // Wall collisions
    _handleWallCollisions();

    // Bottom edge → lose life / remove extra ball
    if (position.y - size.y / 2 > game.size.y) {
      game.onBallLost(this);
      return;
    }
  }

  // ------------------------------------------------------------------
  // Collision callbacks (Flame collision system)
  // ------------------------------------------------------------------
  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Paddle) {
      _handlePaddleCollision(other);
    } else if (other is BrickComponent) {
      _handleBrickCollision(other);
    } else if (other is PowerUpItem) {
      // Power-ups only collide with paddle, not ball
    }
  }

  // ------------------------------------------------------------------
  // Wall collisions
  // ------------------------------------------------------------------
  void _handleWallCollisions() {
    final radius = size.x / 2;

    // Left wall
    if (position.x - radius < 0) {
      position.x = radius;
      velocity.x = velocity.x.abs();
    }
    // Right wall
    if (position.x + radius > game.size.x) {
      position.x = game.size.x - radius;
      velocity.x = -velocity.x.abs();
    }
    // Top wall
    if (position.y - radius < 0) {
      position.y = radius;
      velocity.y = velocity.y.abs();
    }

    // Angle correction: prevent too-shallow bounces
    _correctAngle();
  }

  // ------------------------------------------------------------------
  // Paddle collision
  // ------------------------------------------------------------------
  void _handlePaddleCollision(Paddle paddle) {
    if (velocity.y < 0) return; // only bounce when going down

    // Hit position: -1 (left edge) to +1 (right edge)
    final hitPoint =
        (position.x - paddle.position.x) / (paddle.size.x / 2);

    velocity.x = hitPoint * speed;
    velocity.y = -velocity.y.abs();

    // Place above paddle
    position.y = paddle.position.y - paddle.size.y / 2 - size.y / 2;

    _addRandomFactor();
    game.audioManager.play('hit');
  }

  // ------------------------------------------------------------------
  // Brick collision
  // ------------------------------------------------------------------
  void _handleBrickCollision(BrickComponent brick) {
    if (!game.isBrannasActive) {
      // Determine collision side for deflection
      final dx = position.x - brick.center.x;
      final dy = position.y - brick.center.y;

      if (dx.abs() > dy.abs()) {
        velocity.x = -velocity.x;
      } else {
        velocity.y = -velocity.y;
      }
    }
    // If brannas is active, ball passes straight through

    brick.onHitByBall(this);
    _addRandomFactor();
  }

  // ------------------------------------------------------------------
  // Helpers
  // ------------------------------------------------------------------
  void _addRandomFactor() {
    final factor = (_rng.nextDouble() - 0.5) * 0.2;
    velocity.x += factor * speed;
    velocity.y += factor * speed;
    _normalizeSpeed();
  }

  void _normalizeSpeed() {
    if (velocity.length == 0) return;
    velocity = velocity.normalized() * speed;
  }

  void _correctAngle() {
    if (velocity.length == 0) return;
    var angle = atan2(velocity.y, velocity.x);
    const minAngle = pi / 6; // 30 degrees

    if (angle.abs() < minAngle) {
      angle = minAngle * angle.sign;
      velocity = Vector2(cos(angle), sin(angle)) * speed;
    } else if (angle.abs() > pi - minAngle) {
      angle = (pi - minAngle) * angle.sign;
      velocity = Vector2(cos(angle), sin(angle)) * speed;
    }
  }

  void setDuration(double seconds) {
    _duration = seconds;
    _elapsed = 0;
  }

  void reset() {
    isMoving = false;
    velocity = Vector2.zero();
    speed = config.baseInitialSpeed;
  }

  void increaseSpeed(int currentLevel) {
    final maxSpeed =
        config.baseMaxSpeed * (1 + currentLevel * config.levelSpeedIncrease);
    speed = min(speed * config.speedIncreaseFactor, maxSpeed);
    _normalizeSpeed();
  }
}
