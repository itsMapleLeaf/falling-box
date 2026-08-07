class_name GameConfig

## Shared gameplay dimensions and initial tuning values.
## The authoritative server and clients should both reference these values.

const CELL_SIZE := 50.0
const PLAYER_SIZE := Vector2(40.0, 40.0)
const BOX_SIZE := Vector2(CELL_SIZE, CELL_SIZE)

const ARENA_WIDTH_CELLS := 20
const PLATFORM_WIDTH_CELLS := 18
const PLATFORM_HEIGHT_CELLS := 1

const ARENA_WIDTH := ARENA_WIDTH_CELLS * CELL_SIZE
const PLATFORM_SIZE := Vector2(
	PLATFORM_WIDTH_CELLS * CELL_SIZE,
	PLATFORM_HEIGHT_CELLS * CELL_SIZE
)

const RESPAWN_DELAY_SECONDS := 2.0
const LANDED_BOX_LIFETIME_SECONDS := 15.0
const LANDED_BOX_FADE_SECONDS := 2.0
const FLYING_BOX_MAX_BLOCK_HITS := 2
const FLYING_BOX_LIFETIME_SECONDS := 3.0

const RUN_SPEED := 500.0
const ACCELERATION := 3500.0
const GRAVITY := 1800.0
const JUMP_VELOCITY := -650.0
const MAX_FALL_SPEED := 1200.0
const FLYING_BOX_SPEED := 850.0
