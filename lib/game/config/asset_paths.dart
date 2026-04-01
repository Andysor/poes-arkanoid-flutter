/// Centralised asset path definitions mirroring assets.js from the web version.
///
/// Flame's image loader uses paths relative to `assets/images/`, so paths
/// here should NOT include the `images/` prefix.
library;

class AssetPaths {
  AssetPaths._();

  // -------------------------------------------------------------------------
  // Character sprites
  // -------------------------------------------------------------------------
  static const characters = <String, String>{
    'SAFlag': 'characters/saflag.png',
    'Springbok': 'characters/springbok.png',
    'Voortrekker': 'characters/voortrekker.png',
    'Braai': 'characters/braai.png',
    'RugbyBall': 'characters/rugbyball.png',
  };

  // -------------------------------------------------------------------------
  // Game item sprites
  // -------------------------------------------------------------------------
  static const items = <String, String>{
    'sausage': 'items/sausage.png',
    'coin_gold': 'items/coin_gold.png',
    'coin_silver': 'items/coin_silver.png',
    'brannas': 'items/brannas.png',
    'ball': 'items/ball.png',
    'extraball': 'items/extra_ball.png',
    'paddle_main': 'items/paddle_main.png',
    'powerup_largepaddle': 'items/powerup_largepaddle.png',
    'powerup_smallpaddle': 'items/powerup_smallpaddle.png',
    'extra_life': 'items/extra_life.png',
    'skull': 'items/skull.png',
  };

  // -------------------------------------------------------------------------
  // Brick sprites
  // -------------------------------------------------------------------------
  static const bricks = <String, String>{
    'brick_normal': 'bricks/brick_normal.png',
    'brick_special': 'bricks/brick_special.png',
    'brick_sausage': 'bricks/brick_sausage.png',
    'brick_extra': 'bricks/brick_extra.png',
    'brick_glass': 'bricks/brick_glass.png',
    'brick_glass_broken': 'bricks/brick_glass_broken.png',
  };

  /// Level background image path by level number.
  /// Extensions vary (.jpg, .png, .jpeg) – we try them in order.
  static const levelBackgroundExtensions = ['.jpg', '.png', '.jpeg'];

  static String levelBackground(int levelNum) => 'levels/level$levelNum';

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
    'game_over': 'audio/game_over.m4a',
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
