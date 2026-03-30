import '../config/powerup_config.dart';

/// Manages game audio playback using flame_audio.
///
/// Wraps flame_audio with volume settings per sound type and
/// power-up configuration awareness.
class AudioManager {
  bool _enabled = true;

  /// Volume per sound name matching the web version's volumeMap.
  static const _volumes = <String, double>{
    'hit': 0.1,
    'lifeloss': 0.3,
    'poesklap': 0.8,
    'brannas': 0.8,
    'brick_glass_break': 0.4,
    'brick_glass_destroyed': 0.5,
    'extra_life': 0.6,
    'game_over': 0.7,
    'coin_gold': 0.5,
    'coin_silver': 0.5,
  };

  bool get isEnabled => _enabled;

  void toggle() {
    _enabled = !_enabled;
  }

  /// Play a named sound effect.
  void play(String soundName) {
    if (!_enabled) return;

    final volume = _volumes[soundName] ?? 0.5;

    // TODO: Use FlameAudio.play('$soundName.m4a', volume: volume);
    // Requires flame_audio package and audio files in assets/audio/
    // FlameAudio.play('$soundName.m4a', volume: volume);
  }

  /// Play the sound associated with a power-up type.
  void playForPowerUp(String powerUpType) {
    final cfg = getPowerUpConfig(powerUpType);
    if (cfg != null && cfg.playSound && cfg.sound != null) {
      play(cfg.sound!);
    }
  }
}
