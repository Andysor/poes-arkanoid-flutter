import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../poes_arkanoid_game.dart';
import '../config/game_config.dart' as config;
import '../config/asset_paths.dart';
import 'ball.dart';

/// Brick types matching the web version.
enum BrickType { normal, glass, sausage, extra, special }

/// A single brick in the level grid.
class BrickComponent extends SpriteComponent
    with HasGameReference<PoesArkanoidGame>, CollisionCallbacks {
  BrickComponent({
    required this.brickType,
    required Vector2 brickPosition,
    required Vector2 brickSize,
    this.column = 0,
    this.row = 0,
    this.powerUpType,
  }) : super(
          position: brickPosition,
          size: brickSize,
          anchor: Anchor.topLeft,
          priority: 3,
        );

  final BrickType brickType;
  final int column;
  final int row;

  /// If set, this brick drops the given power-up when destroyed.
  String? powerUpType;

  int _hitCount = 0;
  bool _isBroken = false;

  // ------------------------------------------------------------------
  // Lifecycle
  // ------------------------------------------------------------------
  @override
  Future<void> onLoad() async {
    sprite = Sprite(game.images.fromCache(_texturePath));
    add(RectangleHitbox());
  }

  String get _texturePath {
    switch (brickType) {
      case BrickType.glass:
        return _isBroken
            ? AssetPaths.bricks['brick_glass_broken']!
            : AssetPaths.bricks['brick_glass']!;
      case BrickType.sausage:
        return AssetPaths.bricks['brick_sausage']!;
      case BrickType.extra:
        return AssetPaths.bricks['brick_extra']!;
      case BrickType.special:
        return AssetPaths.bricks['brick_special']!;
      case BrickType.normal:
        return AssetPaths.bricks['brick_normal']!;
    }
  }

  // ------------------------------------------------------------------
  // Hit handling
  // ------------------------------------------------------------------
  void onHitByBall(Ball ball) {
    switch (brickType) {
      case BrickType.glass:
        _handleGlassHit();
      case BrickType.sausage:
        game.addScore(config.pointsSausageBrick);
        _spawnPowerUp();
        _destroy();
      case BrickType.extra:
        game.addScore(config.pointsExtraBallBrick);
        // Spawn extra ball via game
        game.spawnPowerUp('extraball', center);
        _destroy();
      case BrickType.normal:
      case BrickType.special:
        game.addScore(config.pointsNormalBrick);
        _spawnPowerUp();
        _destroy();
    }

    game.audioManager.play('hit');
  }

  void _handleGlassHit() {
    _hitCount++;
    if (_hitCount == 1) {
      // First hit → show cracked texture
      _isBroken = true;
      sprite = Sprite(game.images.fromCache(_texturePath));
      game.addScore(config.pointsGlassFirstHit);
      game.audioManager.play('brick_glass_break');
    } else {
      // Second hit → destroy
      game.addScore(config.pointsGlassDestroyed);
      game.audioManager.play('brick_glass_destroyed');
      _spawnPowerUp();
      _destroy();
    }
  }

  void _spawnPowerUp() {
    if (powerUpType != null) {
      game.spawnPowerUp(powerUpType!, center);
    }
  }

  void _destroy() {
    removeFromParent();
  }
}
