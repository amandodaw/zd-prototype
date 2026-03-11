extends Node2D

@onready var ground_layer = $GroundLayer
@onready var element_layer = $ElementsLayer

var ground_tile : Vector2i = Vector2i(1, 0)
var wood_tile : Vector2i = Vector2i(10, 8)

var entities : Dictionary = {}

const height : int = 52
const width : int = 72

func _ready() -> void:
	init_map()
	add_wood(10)

func init_map() -> void:
	for i in range(width):
		for j in range(height):
			ground_layer.set_cell(Vector2i(i, j), 0, ground_tile)

func add_wood(amount: int) -> void:
	for i in range(amount):

		var pos = Vector2i(
			randi_range(0, width - 1),
			randi_range(0, height - 1)
		)

		# evitar sobreescribir otra entidad
		if pos in entities:
			continue

		element_layer.set_cell(pos, 0, wood_tile)
		entities[pos] = "wood"
