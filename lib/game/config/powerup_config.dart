/// Power-up configuration ported from powerupConfig.js
library;

/// Where the power-up takes effect.
enum PowerUpActivation { brick, paddle, screen }

/// Full configuration for a single power-up type.
class PowerUpBehavior {
  final String spriteKey;
  final bool showSprite;
  final bool showText;
  final String text;
  final String textPosition; // 'center' or 'brick' or 'paddle'
  final double textSize;
  final bool textBlink;
  final bool playSound;
  final String? sound;
  final PowerUpActivation activateOn;
  final double duration; // seconds (0 = instant)
  final int score;

  const PowerUpBehavior({
    required this.spriteKey,
    this.showSprite = true,
    this.showText = false,
    this.text = '',
    this.textPosition = 'center',
    this.textSize = 28,
    this.textBlink = false,
    this.playSound = false,
    this.sound,
    this.activateOn = PowerUpActivation.paddle,
    this.duration = 0,
    this.score = 0,
  });
}

/// All power-up behavior configs keyed by canonical type name.
const Map<String, PowerUpBehavior> powerUpBehaviors = {
  'brannas': PowerUpBehavior(
    spriteKey: 'brannas',
    showText: true,
    text: 'BRANNAS!',
    textPosition: 'center',
    textSize: 32,
    textBlink: true,
    playSound: true,
    sound: 'brannas',
    activateOn: PowerUpActivation.screen,
    duration: 5.0,
    score: 100,
  ),
  'extraball': PowerUpBehavior(
    spriteKey: 'extraball',
    showText: true,
    text: 'POESKLAP!',
    textPosition: 'center',
    textSize: 32,
    textBlink: true,
    playSound: true,
    sound: 'poesklap',
    activateOn: PowerUpActivation.screen,
    duration: 10.0,
    score: 100,
  ),
  'large_paddle': PowerUpBehavior(
    spriteKey: 'powerup_largepaddle',
    showText: false,
    text: 'GROOT!',
    activateOn: PowerUpActivation.paddle,
    duration: 10.0,
  ),
  'small_paddle': PowerUpBehavior(
    spriteKey: 'powerup_smallpaddle',
    showText: false,
    text: 'KLEIN!',
    activateOn: PowerUpActivation.paddle,
    duration: 10.0,
  ),
  'extra_life': PowerUpBehavior(
    spriteKey: 'extra_life',
    showText: false,
    text: 'LIEFLING!',
    playSound: true,
    sound: 'extra_life',
    activateOn: PowerUpActivation.brick,
  ),
  'skull': PowerUpBehavior(
    spriteKey: 'skull',
    showText: false,
    text: 'DOOD!',
    activateOn: PowerUpActivation.brick,
  ),
  'coin_gold': PowerUpBehavior(
    spriteKey: 'coin_gold',
    showText: true,
    text: '100',
    textPosition: 'paddle',
    playSound: true,
    sound: 'coin_gold',
    activateOn: PowerUpActivation.paddle,
    score: 100,
  ),
  'coin_silver': PowerUpBehavior(
    spriteKey: 'coin_silver',
    showText: true,
    text: '25',
    textPosition: 'paddle',
    playSound: true,
    sound: 'coin_silver',
    activateOn: PowerUpActivation.paddle,
    score: 25,
  ),
};

/// How many of each power-up type to distribute per level.
const Map<String, int> powerUpsPerLevel = {
  'brannas': 1,
  'extra_life': 1,
  'skull': 3,
  'coin_gold': 10,
  'coin_silver': 20,
  'large_paddle': 3,
  'small_paddle': 3,
};

/// Look up a power-up behavior config by type string.
/// Handles variations like 'BRANNAS', 'powerup_largepaddle', etc.
PowerUpBehavior? getPowerUpConfig(String type) {
  var key = type.toLowerCase();
  if (key.startsWith('powerup_')) {
    key = key.replaceFirst('powerup_', '');
  }

  // Direct lookup
  if (powerUpBehaviors.containsKey(key)) {
    return powerUpBehaviors[key];
  }

  // Try common variations
  final mappings = <String, String>{
    'largepaddle': 'large_paddle',
    'smallpaddle': 'small_paddle',
    'extralife': 'extra_life',
    'coingold': 'coin_gold',
    'coinsilver': 'coin_silver',
  };

  final mapped = mappings[key];
  if (mapped != null) {
    return powerUpBehaviors[mapped];
  }

  return null;
}
