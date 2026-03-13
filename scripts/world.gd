extends Node2D
class_name World

var human_scene = preload("res://scenes/human.tscn")

@onready var map : Node2D = $Map
@onready var elements_map : TileMapLayer = $Map/ElementsLayer
@onready var ui : Control = $CanvasLayer/UI


var city_comp : CityComponent

func _ready() -> void:
	city_comp = CityComponent.new()
	ui.city_comp = city_comp
	ui.elements_map = elements_map
	map.city_comp = city_comp
	map.init_map()
	for i in range(2+1):
			 
		spawn_human(Vector2(i*GridUtils.TILE_SIZE, i*GridUtils.TILE_SIZE))

func spawn_human(pos: Vector2) -> void:
	if pos in city_comp.entities:
		print("ESPACIO OCUPADO. HUMANO NO SPAWNEADO EN: ", pos)
		return
	var human = human_scene.instantiate()
	human.position = pos
	add_child(human)
	human.city_comp = city_comp
	human.elements_map = elements_map
	human.entity_type = "human"
	city_comp.entities[elements_map.local_to_map(pos)] = "human"
