/// Centralised asset path definitions mirroring assets.js from the web version.
library;

class AssetPaths {
  AssetPaths._();

  // -------------------------------------------------------------------------
  // Character sprites
  // -------------------------------------------------------------------------
  static const characters = <String, String>{
    'SAFlag': 'images/characters/saflag.png',
    'Springbok': 'images/characters/springbok.png',
    'Voortrekker': 'images/characters/voortrekker.png',
    'Braai': 'images/characters/braai.png',
    'RugbyBall': 'images/characters/rugbyball.png',
  };

  // -------------------------------------------------------------------------
  // Game item sprites
  // -------------------------------------------------------------------------
  static const items = <String, String>{
    'sausage': 'images/items/sausage.png',
    'coin_gold': 'images/items/coin_gold.png',
    'coin_silver': 'images/items/coin_silver.png',
    'brannas': 'images/items/brannas.png',
    'ball': 'images/items/ball.png',
    'extraball': 'images/items/extra_ball.png',
    'paddle_main': 'images/items/paddle_main.png',
    'powerup_largepaddle': 'images/items/powerup_largepaddle.png',
    'powerup_smallpaddle': 'images/items/powerup_smallpaddle.png',
    'extra_life': 'images/items/extra_life.png',
    'skull': 'images/items/skull.png',
  };

  // -------------------------------------------------------------------------
  // Brick sprites
  // -------------------------------------------------------------------------
  static const bricks = <String, String>{
    'brick_normal': 'images/bricks/brick_normal.png',
    'brick_special': 'images/bricks/brick_special.png',
    'brick_sausage': 'images/bricks/brick_sausage.png',
    'brick_extra': 'images/bricks/brick_extra.png',
    'brick_glass': 'images/bricks/brick_glass.png',
    'brick_glass_broken': 'images/bricks/brick_glass_broken.png',
  };

  /// Level background image path by level number.
  /// Extensions vary (.jpg, .png, .jpeg) – we try them in order.
  static const levelBackgroundExtensions = ['.jpg', '.png', '.jpeg'];

  static String levelBackground(int levelNum) =>
      'images/levels/level$levelNum';

  // -------------------------------------------------------------------------
  // Audio files (m4a format – native friendly)
  // -------------------------------------------------------------------------
  static const audio = <String, String>{
    'hit': 'audio/hit.m4a',
    'lifeloss': 'audio/lifeloss.m4a',
    'poesklap': 'audio/poesklap.m4a',
    'brannas': 'audio/brannas.m4a',
    'brick_glass_break': 'audio/brick_glass_break.m4a',
    'brick_glass_destroyed': 'audio/brick_glass_destroyed.m4a',
    'extra_life': 'audio/extra_life.m4a',
    'coin_silver': 'audio/coin_silver.m4a',
    'coin_gold': 'audio/coin_gold.m4a',
    'game_over': 'audio/game_over1.m4a',
  };

  // -------------------------------------------------------------------------
  // Level data JSON
  // -------------------------------------------------------------------------
  static String levelData(int levelNum) => 'assets/levels/level$levelNum.json';

  // -------------------------------------------------------------------------
  // All image paths for preloading
  // -------------------------------------------------------------------------
  static List<String> get allImages => [
        ...characters.values,
        ...items.values,
        ...bricks.values,
      ];
}
