extends Node2D
class_name World

var human_scene = preload("res://scenes/human.tscn")

@onready var map : Node2D = $Map
@onready var elements_map : TileMapLayer = $Map/ElementsLayer

var city_component : CityComponent

func _ready() -> void:
	city_component = CityComponent.new()
	spawn_human(Vector2.ZERO)

func spawn_human(pos: Vector2) -> void:
	if pos in map.entities:
		print("ESPACIO OCUPADO. HUMANO NO SPAWNEADO EN: ", pos)
		return
	var human = human_scene.instantiate()
	human.position = pos
	add_child(human)
	map.entities[elements_map.local_to_map(pos)] = "human"
