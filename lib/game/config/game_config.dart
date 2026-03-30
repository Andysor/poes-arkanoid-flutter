/// Game configuration constants ported from the web version's config.js
library;

const String gameVersion = '1.0.0';

// ---------------------------------------------------------------------------
// Ball settings
// ---------------------------------------------------------------------------
/// Base speed at game start (units per frame in the web version).
/// In Flame we multiply by dt, so this is effectively pixels/second base.
const double baseInitialSpeed = 300.0;

/// Absolute maximum ball speed.
const double baseMaxSpeed = 900.0;

/// Speed increase per level (15%).
const double levelSpeedIncrease = 0.15;

/// Ball radius as fraction of screen width.
const double ballRadiusFraction = 0.02;

// ---------------------------------------------------------------------------
// Paddle settings
// ---------------------------------------------------------------------------
/// Paddle width as fraction of screen width.
const double paddleWidthFraction = 0.20;

/// Paddle height as fraction of screen height.
const double paddleHeightFraction = 0.02;

/// Distance from bottom edge (fraction of screen height).
const double paddleBottomMarginFraction = 0.12;

/// Hover offset above touch point (fraction of screen height).
const double paddleHoverOffset = 0.10;

/// Lerp factor for smooth paddle movement (0..1).
const double paddleLerp = 0.2;

/// Paddle extend multiplier for large paddle power-up.
const double paddleExtendMultiplier = 1.5;

/// Paddle shrink multiplier for small paddle power-up.
const double paddleShrinkMultiplier = 0.75;

// ---------------------------------------------------------------------------
// Brick grid
// ---------------------------------------------------------------------------
const int brickColumns = 15;
const int brickRows = 9;

/// Fraction of screen width used for the brick area.
const double brickAreaWidthFraction = 0.90;

/// Padding between bricks in logical pixels.
const double brickPadding = 3.0;

/// Offset from top edge (fraction of screen height).
const double brickOffsetTopFraction = 0.05;

// ---------------------------------------------------------------------------
// Power-up settings
// ---------------------------------------------------------------------------
/// Duration of timed power-ups in seconds.
const double powerUpDuration = 10.0;

/// Falling speed of power-up items (pixels per second).
const double powerUpFallingSpeed = 300.0;

// ---------------------------------------------------------------------------
// Scoring
// ---------------------------------------------------------------------------
const int pointsNormalBrick = 10;
const int pointsGlassFirstHit = 5;
const int pointsGlassDestroyed = 20;
const int pointsSausageBrick = 50;
const int pointsExtraBallBrick = 50;
const int pointsGoldCoin = 100;
const int pointsSilverCoin = 25;
const int pointsBrannas = 100;
const int pointsExtraBall = 100;

// ---------------------------------------------------------------------------
// Game settings
// ---------------------------------------------------------------------------
const int initialLives = 3;
const int maxLevel = 100;

// ---------------------------------------------------------------------------
// Speed ramping
// ---------------------------------------------------------------------------
/// Seconds between automatic speed increases during play.
const double speedIncreaseInterval = 10.0;

/// Multiplier applied at each speed increase tick.
const double speedIncreaseFactor = 1.1;

// ---------------------------------------------------------------------------
// Brannas duration in seconds.
// ---------------------------------------------------------------------------
const double brannasDuration = 5.0;
