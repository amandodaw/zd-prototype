extends Node2D
class_name World

var human_scene = preload("res://scenes/human.tscn")
var zombie_scene = preload("res://scenes/zombie.tscn")
var entity_scene = preload("res://scenes/entity.tscn")

@onready var map : Node2D = $Map
@onready var elements_map : TileMapLayer = $Map/ElementsLayer
@onready var ui : Control = $CanvasLayer/UI


var city_comp : CityComponent

var astar = AStarGrid2D.new()

var systems : Array = []

var entities : Array[Entity] = []

var ai_system : AISystem
var target_system : TargetSystem
var path_system : PathSystem

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
	
	spawn_zombie(Vector2(16*GridUtils.TILE_SIZE, 16*GridUtils.TILE_SIZE))
	
	ai_system = AISystem.new()
	target_system = TargetSystem.new()
	path_system = PathSystem.new()
	path_system.astar = astar
	

func _process(delta: float) -> void:
	ai_system.update(delta, entities)
	target_system.update(delta, entities)
	path_system.update(delta, entities)

func spawn_human(pos: Vector2) -> void:
	var cell = elements_map.local_to_map(pos)

	if cell in city_comp.entities:
		print("ESPACIO OCUPADO. HUMANO NO SPAWNEADO EN: ", pos)
		return
	var human : Entity = human_scene.instantiate()
	human.add_component(HealthComponent.new())
	human.add_component(PositionComponent.new())
	human.add_component(TargetComponent.new())
	human.add_component(PathComponent.new())
	human.add_component(AIComponent.new())
	human.position = pos
	human.get_component(PositionComponent).grid_pos = elements_map.local_to_map(pos)
	add_child(human)
	human.city_comp = city_comp
	human.get_component(AIComponent).city_comp = city_comp
	human.elements_map = elements_map
	human.entity_type = "human"
	city_comp.living_entities.set(cell, human)
	entities.append(human)

func spawn_zombie(pos: Vector2) -> void:
	var cell = elements_map.local_to_map(pos)

	if cell in city_comp.entities:
		print("ESPACIO OCUPADO. HUMANO NO SPAWNEADO EN: ", pos)
		return
	var zombie : Entity = zombie_scene.instantiate()
	zombie.add_component(HealthComponent.new())
	zombie.add_component(PositionComponent.new())
	zombie.add_component(TargetComponent.new())
	zombie.position = pos
	zombie.get_component(PositionComponent).grid_pos = elements_map.local_to_map(pos)
	add_child(zombie)
	zombie.city_comp = city_comp
	zombie.elements_map = elements_map
	zombie.entity_type = "zombie"
	city_comp.living_entities.set(cell, zombie)
