import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../poes_arkanoid_game.dart';
import '../config/game_config.dart' as config;
import '../config/powerup_config.dart';
import 'paddle.dart';

/// A falling power-up item that the player catches with the paddle.
class PowerUpItem extends SpriteComponent
    with HasGameReference<PoesArkanoidGame>, CollisionCallbacks {
  PowerUpItem({
    required this.type,
    required Vector2 startPosition,
  }) : super(
          position: startPosition,
          size: Vector2.all(30),
          anchor: Anchor.center,
          priority: 8,
        );

  final String type;
  late final PowerUpBehavior? _config;

  @override
  Future<void> onLoad() async {
    _config = getPowerUpConfig(type);

    final spriteKey = _config?.spriteKey ?? type.toLowerCase();
    final imagePath = 'images/items/$spriteKey.png';

    try {
      sprite = Sprite(game.images.fromCache(imagePath));
    } catch (_) {
      // If image not found, use a fallback
      sprite = Sprite(game.images.fromCache('images/items/coin_gold.png'));
    }

    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Fall downward
    position.y += config.powerUpFallingSpeed * dt;

    // Remove if off screen
    if (position.y > game.size.y + size.y) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(Set<Vector2> points, PositionComponent other) {
    super.onCollisionStart(points, other);

    if (other is Paddle) {
      game.collectPowerUp(this);
    }
  }
}
