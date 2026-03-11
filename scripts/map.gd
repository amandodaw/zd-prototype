extends Node2D

@onready var ground_layer = $GroundLayer

var ground_tile : Vector2i = Vector2i(1, 0)

const height : int = 50
const width : int = 50

func _ready() -> void:
	init_map()

func init_map() -> void:
	for i in range(height):
		for j in range(width):
			ground_layer.set_cell(Vector2i(i, j), 0, ground_tile)
