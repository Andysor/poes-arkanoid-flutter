import 'dart:ui';

import 'package:flame/components.dart';

/// Canvas-based ball trail effect.
///
/// Uses plain data objects instead of Flame components for particles.
/// Single render() call draws all particles — no scene graph overhead.
class BallTrail extends Component {
  static const int _maxParticles = 20;
  static const double _particleLifetime = 0.25;
  static const int _spawnInterval = 3; // spawn every Nth frame

  final List<_Particle> _particles = [];
  int _frameCount = 0;

  /// Call from the game loop with the ball's current position and radius.
  void addParticle(Vector2 pos, double radius) {
    _frameCount++;
    if (_frameCount % _spawnInterval != 0) return;

    if (_particles.length >= _maxParticles) {
      _particles.removeAt(0);
    }
    _particles.add(_Particle(
      x: pos.x,
      y: pos.y,
      radius: radius * 0.8,
      life: _particleLifetime,
    ));
  }

  @override
  void update(double dt) {
    _particles.removeWhere((p) {
      p.elapsed += dt;
      return p.elapsed >= p.life;
    });
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint();
    for (final p in _particles) {
      final t = (p.elapsed / p.life).clamp(0.0, 1.0);
      paint.color = const Color.fromRGBO(245, 138, 66, 1.0)
          .withValues(alpha: (1.0 - t) * 0.5);
      canvas.drawCircle(
        Offset(p.x, p.y),
        p.radius * (1.0 - t * 0.5),
        paint,
      );
    }
  }

  void clear() {
    _particles.clear();
  }
}

class _Particle {
  _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.life,
  });

  final double x;
  final double y;
  final double radius;
  final double life;
  double elapsed = 0;
}
