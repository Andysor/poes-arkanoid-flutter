import 'dart:ui';

import 'package:flame/components.dart';

import '../poes_arkanoid_game.dart';

/// Particle-based ball trail effect.
///
/// Spawns small fading circles behind the ball.
/// Uses Flame's [CircleComponent] for each particle.
class BallTrail extends Component with HasGameReference<PoesArkanoidGame> {
  BallTrail({
    this.trailColor = const Color(0xFFF58A42), // orange for main ball
    this.maxParticles = 15,
    this.particleLifetime = 0.25, // seconds
  });

  final Color trailColor;
  final int maxParticles;
  final double particleLifetime;

  final List<_TrailParticle> _particles = [];

  /// Call each frame with the ball's current position and radius.
  void addParticle(Vector2 pos, double radius) {
    final p = _TrailParticle(
      position: pos.clone(),
      radius: radius * 0.8,
      color: trailColor,
      lifetime: particleLifetime,
    );
    _particles.add(p);
    add(p);

    // Remove oldest if over limit
    if (_particles.length > maxParticles) {
      final oldest = _particles.removeAt(0);
      oldest.removeFromParent();
    }
  }

  void clear() {
    for (final p in _particles) {
      p.removeFromParent();
    }
    _particles.clear();
  }
}

class _TrailParticle extends CircleComponent {
  _TrailParticle({
    required Vector2 position,
    required double radius,
    required Color color,
    required this.lifetime,
  }) : super(
          position: position,
          radius: radius,
          anchor: Anchor.center,
          paint: Paint()..color = color,
        );

  final double lifetime;
  double _elapsed = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    final t = (_elapsed / lifetime).clamp(0.0, 1.0);
    paint.color = paint.color.withValues(alpha: (1.0 - t) * 0.5);

    if (_elapsed >= lifetime) {
      removeFromParent();
    }
  }
}
