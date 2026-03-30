# Poes Arkanoid – Flutter/Flame Port

## What is this?

A Flutter + Flame port of **PoesArkanoid**, a South African themed Arkanoid/Breakout clone. The original is a web game built with PixiJS (see `../PoesArkanoid-dev/`). This repo is the native mobile port targeting iOS first, then Android.

## Tech Stack

- **Flutter 3.27+** / Dart 3.6+
- **Flame 1.22+** – 2D game engine (sprites, collision, game loop)
- **flame_audio** – Native audio playback
- **Firebase** (cloud_firestore + firebase_core) – High scores / leaderboard

## Project Structure

```
lib/
  main.dart                          # App entry point, screen flow
  screens/
    name_input_screen.dart           # Player name entry (Flutter widget)
    character_select_screen.dart     # Character picker (Flutter widget)
  game/
    poes_arkanoid_game.dart          # Main FlameGame class, game state, input
    config/
      game_config.dart               # All gameplay constants (speed, sizes, scoring)
      powerup_config.dart            # Power-up behaviors and distribution
      asset_paths.dart               # Centralised asset path definitions
    components/
      ball.dart                      # Ball physics, collision, speed ramping
      paddle.dart                    # Paddle movement (lerp), size power-ups
      brick.dart                     # Brick types (normal, glass, sausage, extra, special)
      level.dart                     # Level loading from JSON, brick grid creation
      power_up.dart                  # Falling power-up items
      ball_trail.dart                # Particle trail effect behind ball
    managers/
      audio_manager.dart             # Sound playback with per-sound volume config
assets/
  images/                            # PNG sprites (characters, items, bricks, levels)
  audio/                             # m4a sound effects
  levels/                            # JSON level definitions (22 levels)
```

## Original Web Source Reference

The original JS source lives in `../PoesArkanoid-dev/PoesArkanoid-dev/js/`. Key mapping:

| Web (JS)              | Flutter (Dart)                              |
|-----------------------|---------------------------------------------|
| config.js             | lib/game/config/game_config.dart            |
| powerupConfig.js      | lib/game/config/powerup_config.dart         |
| assets.js             | lib/game/config/asset_paths.dart            |
| game.js               | lib/game/poes_arkanoid_game.dart            |
| ball.js               | lib/game/components/ball.dart               |
| paddle.js             | lib/game/components/paddle.dart             |
| brick.js              | lib/game/components/brick.dart              |
| level.js              | lib/game/components/level.dart              |
| powerup.js            | lib/game/components/power_up.dart           |
| ballTrail.js          | lib/game/components/ball_trail.dart         |
| audio.js              | lib/game/managers/audio_manager.dart        |
| main.js               | lib/main.dart                               |
| gameOverManager.js    | Game over overlay in main.dart              |

## Key Gameplay Mechanics

- **Ball physics**: Custom AABB collision (not Flame's physics engine). Hit-position on paddle steers ball angle. Random factor after each bounce. Speed ramps 10% every 10 seconds.
- **Brick types**: Normal (1 hit), Glass (2 hits with cracked texture), Sausage (drops sausage), Extra (spawns extra ball), Special.
- **8 power-up types**: Brannas (pass-through), Extra Ball, Large/Small Paddle, Extra Life, Skull (lose life), Gold/Silver Coin. Distributed with weighted random (glass bricks 3x weight).
- **Brannas effect**: Ball passes through bricks without deflecting for 5 seconds.
- **Level format**: JSON files with 15×9 grid. Each cell has type, destroyed, etc.

## Build & Run

```bash
# Install Flutter, then:
flutter pub get
flutter run          # iOS simulator or connected device

# Generate platform dirs if needed:
flutter create --platforms=ios .
```

## Conventions

- Game constants go in `game_config.dart` (not hardcoded in components)
- Power-up behavior goes in `powerup_config.dart`
- All asset paths centralised in `asset_paths.dart`
- Components use Flame's `HasGameReference<PoesArkanoidGame>` mixin
- UI screens (name input, character select, game over) are Flutter widgets, not Flame
- Game mechanics (paddle, ball, bricks) are Flame components

## Current Status

**Scaffolded** – all classes and config ported. Next steps:
1. Run `flutter create --platforms=ios .` on macOS to generate iOS project
2. Copy assets from web project into `assets/`
3. Wire up `flame_audio` in AudioManager
4. Integrate Firebase for high scores
5. Playtest and tune physics feel (speed, angles, lerp values)
6. Add level backgrounds
7. Game over / high score screens
