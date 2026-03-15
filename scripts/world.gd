extends Node2D
class_name World

var human_scene = preload("res://scenes/human.tscn")

@onready var map : Node2D = $Map
@onready var elements_map : TileMapLayer = $Map/ElementsLayer
@onready var ui : Control = $CanvasLayer/UI


var city_comp : CityComponent

var astar = AStarGrid2D.new()

func _ready() -> void:
	city_comp = CityComponent.new()
	city_comp.astar = astar
	map.city_comp = city_comp
	map.init_map()
	
	var ground_layer : TileMapLayer = map.ground_layer
	astar.region = ground_layer.get_used_rect()
	astar.cell_size = Vector2(GridUtils.TILE_SIZE, GridUtils.TILE_SIZE)

	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER

	astar.update()

	map.add_wood(30)

	ui.city_comp = city_comp
	ui.elements_map = elements_map
	for i in range(2+1):
		
		spawn_human(Vector2(i*GridUtils.TILE_SIZE, i*GridUtils.TILE_SIZE))


func spawn_human(pos: Vector2) -> void:
	var cell = elements_map.local_to_map(pos)

	if cell in city_comp.entities:
		print("ESPACIO OCUPADO. HUMANO NO SPAWNEADO EN: ", pos)
		return
	var human = human_scene.instantiate()
	human.position = pos
	human.grid_pos = elements_map.local_to_map(pos)
	add_child(human)
	human.city_comp = city_comp
	human.elements_map = elements_map
	human.entity_type = "human"
	city_comp.entities[elements_map.local_to_map(pos)] = "human"
