# PoesArkanoid: Unity 3D Rewrite

## Context

The Flutter/Flame 2D version is functionally complete but visually flat. The user wants full 3D rendering with dynamic camera, animated backgrounds, and premium visual effects. Decision: rewrite in Unity (C#), targeting iOS first, Android second.

The existing Flutter project and original JS source serve as reference implementations for game logic, level formats, and asset inventory.

---

## Prerequisites

1. **Install Unity Hub + Unity Editor** (LTS version, e.g. 2022.3 LTS or 6000.x)
   - Include iOS Build Support module
   - Include Android Build Support module (for later)
2. **Xcode** — already installed
3. **Firebase Unity SDK** — for high scores

---

## Phase 1: Project Setup

1. Create new Unity 3D project (URP — Universal Render Pipeline for mobile-optimized 3D)
2. Configure for iOS: Player Settings → iOS bundle ID, deployment target 13.0+
3. Set up folder structure:
   ```
   Assets/
     Scripts/
       Game/          # GameManager, GameState, InputManager
       Components/    # Ball, Paddle, Brick, PowerUp, Level
       Config/        # GameConfig, PowerUpConfig
       Audio/         # AudioManager
       UI/            # NameInput, CharacterSelect, HUD, GameOver
       Services/      # FirebaseService
     Prefabs/         # Ball, Paddle, Brick variants, PowerUp variants
     Materials/       # Brick materials, ball material, paddle material
     Audio/           # .m4a sound effects (copy from Flutter assets/)
     Levels/          # JSON level definitions (copy from Flutter assets/levels/)
     Textures/        # Character sprites, UI elements
     Shaders/         # Custom shaders if needed
   ```

---

## Phase 2: 3D Models & Materials

### Bricks
- **Geometry:** Rounded box mesh (slight bevel on edges)
- **Materials (URP Lit):**
  - Normal: blue metallic with subtle roughness variation
  - Glass: transparent/refractive material, frosted look
  - Sausage: gold/bronze metallic
  - Extra: green emissive glow
  - Special: red with animated emissive pulse
- **Effects:** 
  - Crack shader on glass brick first hit
  - Destruction: shatter into rigid body fragments with physics
  - Shadow casting onto background

### Ball
- **Geometry:** Sphere with high-gloss material
- **Material:** Emissive + reflective (environment probe)
- **Effects:**
  - Point light attached (illuminates nearby bricks)
  - Trail renderer (Unity's built-in TrailRenderer component)
  - Brannas state: cyan emissive glow + distortion post-process

### Paddle
- **Geometry:** Rounded box with metallic material
- **Effects:**
  - Reflective surface catching ball light
  - Size change via smooth tween animation
  - Power-up state: colored emissive rim

### Power-ups
- **Geometry:** 3D icon meshes (coin, skull, etc.) or textured quads
- **Effects:**
  - Spin animation (Y-axis rotation)
  - Point light / glow
  - Particle trail while falling

---

## Phase 3: Game Logic Port (JS/Dart → C#)

Port from the Flutter reference. Key classes:

| Flutter (Dart) | Unity (C#) |
|----------------|------------|
| `PoesArkanoidGame` | `GameManager` (MonoBehaviour) |
| `Ball` | `Ball` (MonoBehaviour on sphere prefab) |
| `Paddle` | `Paddle` (MonoBehaviour on paddle prefab) |
| `BrickComponent` | `Brick` (MonoBehaviour on brick prefab) |
| `Level` | `LevelLoader` (loads JSON, instantiates brick grid) |
| `PowerUpItem` | `PowerUp` (MonoBehaviour on powerup prefab) |
| `AudioManager` | `AudioManager` (singleton, uses Unity AudioSource pool) |
| `GameConfig` | `GameConfig` (ScriptableObject) |

### Game state machine
Same states as Flutter: `WaitForStart → Playing → GameOver`
- Unity's `Time.timeScale = 0` for pause (instead of Flame's `pauseEngine()`)

### Ball physics
- Port the custom AABB collision logic (don't use Unity's built-in physics for gameplay — keep the same feel as JS/Flutter)
- OR use Unity Rigidbody with custom collision response for more natural 3D feel

### Level loading
- Same JSON format (15×9 grid)
- Copy all 22 JSON files from `assets/levels/`
- Parse with Unity's `JsonUtility` or `Newtonsoft.Json`

### Input
- Touch input for paddle: `Input.GetTouch()` or new Input System
- Tap to launch ball

---

## Phase 4: Camera & Perspective

### Dynamic camera system
- **Default view:** Slight top-down angle (15-20° tilt) looking at the brick field
- **Ball tracking:** Camera subtly follows ball Y position (parallax effect)
- **Impact zoom:** Brief zoom pulse on brick destruction
- **Level overview:** Camera pulls back briefly when new level loads
- **Game over:** Camera slowly rotates/pulls back for dramatic effect

### Implementation
- Cinemachine (Unity's camera system) with virtual cameras:
  - `GameplayCam` — main gameplay angle with damped follow
  - `OverviewCam` — wide shot for level transitions
  - `GameOverCam` — cinematic pullback
- Blend between cameras on state transitions

---

## Phase 5: Animated Backgrounds

### Layer 1: Gradient sky
- Procedural gradient shader that shifts colors slowly over time
- Different color palettes per level (warm → cool → dramatic)

### Layer 2: Particle systems
- Floating particles (embers, stars, dust) using Unity Particle System
- Responds subtly to gameplay (more particles on destruction)

### Layer 3: Level-specific elements
- Reuse existing level background images as textured planes behind the game
- Add parallax depth (multiple layers at different Z positions)
- Subtle animation (slow pan, parallax shift with camera)

---

## Phase 6: Visual Effects

### Post-processing (URP)
- **Bloom:** Ball and emissive bricks glow
- **Vignette:** Subtle edge darkening for focus
- **Color grading:** Per-level color temperature
- **Motion blur:** Subtle on fast ball movement

### Particle effects
- **Brick destruction:** Mesh fragments + sparks + dust
- **Power-up collection:** Burst of colored particles
- **Ball bounce:** Small spark/flash on collision point
- **Brannas activation:** Screen-wide cyan pulse

### Screen shake
- Cinemachine Impulse system for camera shake on impacts

---

## Phase 7: Audio

- Copy all `.m4a` files from Flutter `assets/audio/`
- Unity AudioSource pool pattern (same concept as Flame AudioPool)
- 3D spatial audio: sounds positioned at impact points

---

## Phase 8: UI

- Unity UI Toolkit or uGUI for:
  - Name input screen
  - Character select (with 3D character preview instead of 2D sprites)
  - HUD (score, lives, level)
  - Game over + high scores

---

## Phase 9: Firebase Integration

- Firebase Unity SDK (com.google.firebase)
- Same Firestore collection structure (`highscores`)
- Same fields: name, score, level, timestamp

---

## Phase 10: iOS Build & Test

- Build for iOS in Xcode
- Profile mode testing
- TestFlight distribution

---

## Assets to reuse from Flutter project

| Asset | Source | Notes |
|-------|--------|-------|
| 22 level JSONs | `assets/levels/` | Copy directly, same format |
| 10 audio files | `assets/audio/` | Copy directly, .m4a works in Unity |
| Level backgrounds | `assets/images/levels/` | Use as background textures |
| Character sprites | `assets/images/characters/` | For character select UI |
| GoogleService-Info.plist | `ios/Runner/` | Firebase config |

### Assets to CREATE new
- 3D brick meshes (5 types) — can be simple rounded boxes in ProBuilder or Blender
- 3D ball mesh (sphere with material)
- 3D paddle mesh (rounded box)
- Power-up meshes or keep as textured quads with 3D effects
- Particle textures for destruction/trails

---

## Verification

1. Unity project builds for iOS
2. Level 1 loads from JSON with 3D bricks
3. Ball bounces with trail and glow
4. Paddle follows touch input
5. Bricks shatter on destruction with particles
6. Camera shifts dynamically during gameplay
7. Animated gradient background with particles
8. Audio plays without lag (AudioSource pool)
9. Firebase high scores submit and display
10. Smooth 60fps on iPhone in Release build
