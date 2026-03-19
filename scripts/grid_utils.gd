class_name GridUtils

const TILE_SIZE : int = 16

const grid_offset : Vector2i = Vector2i(TILE_SIZE/2, TILE_SIZE/2)

const INVALID := Vector2i(-1,-1)

enum direction {
	UP,
	DOWN,
	LEFT,
	RIGHT
}

const DIR = [
	Vector2i(0, -1),
	Vector2i(0, 1),
	Vector2i(1, 0),
	Vector2i(-1, 0)
]
