extends Sprite2D

var target_pos : Vector2i = Vector2i.ZERO
var grid_pos : Vector2i = Vector2i.ZERO

var speed : int = 100


func move_to(dir : GridUtils.direction) -> void:
	grid_pos += GridUtils.DIR[dir]
	position = grid_pos * GridUtils.TILE_SIZE + GridUtils.grid_offset

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		move_to(GridUtils.direction.LEFT)
