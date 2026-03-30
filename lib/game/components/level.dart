import 'dart:convert';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/services.dart';

import '../poes_arkanoid_game.dart';
import '../config/game_config.dart' as config;
import '../config/powerup_config.dart';
import 'brick.dart';

/// Manages loading a level from JSON and creating the brick grid.
class Level extends Component with HasGameReference<PoesArkanoidGame> {
  Level({required this.levelNumber});

  final int levelNumber;

  final List<BrickComponent> _bricks = [];

  late double brickWidth;
  late double brickHeight;
  late double _offsetLeft;
  late double _offsetTop;

  bool get isComplete => _bricks.every((b) => !b.isMounted);

  // ------------------------------------------------------------------
  // Lifecycle
  // ------------------------------------------------------------------
  @override
  Future<void> onLoad() async {
    await _calculateDimensions();
    await _loadLevel();
  }

  void _calculateDimensions() {
    final totalWidth = game.size.x * config.brickAreaWidthFraction;
    brickWidth = (totalWidth -
            config.brickPadding * (config.brickColumns - 1)) /
        config.brickColumns;
    brickHeight = brickWidth; // 1:1 aspect ratio
    _offsetLeft = (game.size.x - totalWidth) / 2;
    _offsetTop = game.size.y * config.brickOffsetTopFraction;
  }

  // ------------------------------------------------------------------
  // Level loading
  // ------------------------------------------------------------------
  Future<void> _loadLevel() async {
    try {
      final jsonStr = await rootBundle
          .loadString('assets/levels/level$levelNumber.json');
      final data = jsonDecode(jsonStr);
      _createBricksFromData(data);
    } catch (e) {
      // Fallback: create a default grid of normal bricks
      _createDefaultLevel();
    }
  }

  void _createBricksFromData(dynamic data) {
    // Handle both formats: { bricks: [...] } or direct 2D array
    final List<dynamic> bricksData =
        data is Map && data.containsKey('bricks')
            ? data['bricks'] as List<dynamic>
            : data as List<dynamic>;

    final normalBricks = <BrickComponent>[];
    final glassBricks = <BrickComponent>[];

    for (int r = 0; r < bricksData.length; r++) {
      final row = bricksData[r] as List<dynamic>;
      for (int c = 0; c < row.length; c++) {
        final info = row[c] as Map<String, dynamic>;
        if (info['destroyed'] == true) continue;

        final typeStr = (info['type'] as String?) ?? 'normal';
        final brickType = _parseBrickType(typeStr);

        final x = c * (brickWidth + config.brickPadding) + _offsetLeft;
        final y = r * (brickHeight + config.brickPadding) + _offsetTop;

        final brick = BrickComponent(
          brickType: brickType,
          brickPosition: Vector2(x, y),
          brickSize: Vector2(brickWidth, brickHeight),
          column: c,
          row: r,
        );

        _bricks.add(brick);
        add(brick);

        if (brickType == BrickType.normal) {
          normalBricks.add(brick);
        } else if (brickType == BrickType.glass) {
          glassBricks.add(brick);
        }
      }
    }

    // Distribute power-ups across bricks (glass bricks weighted 3x)
    _distributePowerUps(normalBricks, glassBricks);
  }

  void _createDefaultLevel() {
    for (int c = 0; c < config.brickColumns; c++) {
      for (int r = 0; r < config.brickRows; r++) {
        final x = c * (brickWidth + config.brickPadding) + _offsetLeft;
        final y = r * (brickHeight + config.brickPadding) + _offsetTop;

        final brick = BrickComponent(
          brickType: BrickType.normal,
          brickPosition: Vector2(x, y),
          brickSize: Vector2(brickWidth, brickHeight),
          column: c,
          row: r,
        );
        _bricks.add(brick);
        add(brick);
      }
    }
  }

  // ------------------------------------------------------------------
  // Power-up distribution (matches JS weighted algorithm)
  // ------------------------------------------------------------------
  void _distributePowerUps(
    List<BrickComponent> normalBricks,
    List<BrickComponent> glassBricks,
  ) {
    final weighted = <BrickComponent>[
      ...normalBricks, // weight 1
      ...glassBricks,
      ...glassBricks,
      ...glassBricks, // weight 3
    ];

    weighted.shuffle(Random());

    int index = 0;
    for (final entry in powerUpsPerLevel.entries) {
      for (int i = 0; i < entry.value && index < weighted.length; i++) {
        weighted[index].powerUpType = entry.key;
        index++;
      }
    }
  }

  // ------------------------------------------------------------------
  // Helpers
  // ------------------------------------------------------------------
  static BrickType _parseBrickType(String type) {
    switch (type.toLowerCase()) {
      case 'glass':
        return BrickType.glass;
      case 'sausage':
        return BrickType.sausage;
      case 'extra':
        return BrickType.extra;
      case 'special':
        return BrickType.special;
      default:
        return BrickType.normal;
    }
  }
}
