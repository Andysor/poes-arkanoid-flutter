import 'dart:async';

import 'package:flame_audio/flame_audio.dart';

import '../config/powerup_config.dart';

/// Manages game audio playback using Flame AudioPool.
///
/// All pools are preloaded sequentially during onLoad() to avoid
/// overwhelming the iOS audio daemon. GameWidget.loadingBuilder
/// shows a loading indicator while this runs.
class AudioManager {
  bool _enabled = true;
  final Map<String, AudioPool> _pools = {};

  static const _configs = <String, ({int min, int max, double volume})>{
    'hit':                   (min: 4, max: 8,  volume: 0.10),
    'brick_glass_break':     (min: 2, max: 4,  volume: 0.40),
    'brick_glass_destroyed': (min: 2, max: 4,  volume: 0.50),
    'brannas':               (min: 1, max: 2,  volume: 0.80),
    'poesklap':              (min: 1, max: 2,  volume: 0.80),
    'coin_gold':             (min: 1, max: 3,  volume: 0.50),
    'coin_silver':           (min: 1, max: 3,  volume: 0.50),
    'extra_life':            (min: 1, max: 2,  volume: 0.60),
    'lifeloss':              (min: 1, max: 2,  volume: 0.30),
    'game_over':             (min: 1, max: 1,  volume: 0.70),
  };

  bool get isEnabled => _enabled;

  void toggle() => _enabled = !_enabled;

  /// Preload all audio pools sequentially.
  Future<void> preloadAll() async {
    for (final entry in _configs.entries) {
      _pools[entry.key] = await FlameAudio.createPool(
        '${entry.key}.m4a',
        minPlayers: entry.value.min,
        maxPlayers: entry.value.max,
      );
    }
  }

  /// Play a named sound effect from its pool.
  void play(String soundName) {
    if (!_enabled) return;
    final pool = _pools[soundName];
    final cfg = _configs[soundName];
    if (pool == null || cfg == null) return;
    unawaited(pool.start(volume: cfg.volume));
  }

  /// Play the sound associated with a power-up type.
  void playForPowerUp(String powerUpType) {
    final cfg = getPowerUpConfig(powerUpType);
    if (cfg != null && cfg.playSound && cfg.sound != null) {
      play(cfg.sound!);
    }
  }

  /// Dispose all pools. Call when the game is removed.
  Future<void> dispose() async {
    for (final pool in _pools.values) {
      await pool.dispose();
    }
    _pools.clear();
  }
}
