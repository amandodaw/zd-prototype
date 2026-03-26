extends Node2D

@onready var ground_layer = $GroundLayer
@onready var element_layer = $ElementsLayer

var ground_tile : Vector2i = Vector2i(1, 0)
var wood_tile : Vector2i = Vector2i(10, 8)

var entities : Array[Entity]

@onready var city_comp : CityComponent

const height : int = 52
const width : int = 72

func _process(delta: float) -> void:
	check_wood()

func init_map() -> void:
	create_soil()

func create_soil() -> void:
	for i in range(width):
		for j in range(height):
			ground_layer.set_cell(Vector2i(i, j), 0, ground_tile)

func add_wood_random(amount: int) -> void:
	var invalid_tiles = get_entity_tiles()
	for i in range(amount):

		var pos = Vector2i(
			randi_range(0, width - 1),
			randi_range(0, height - 1)
		)

		# evitar sobreescribir otra entidad
		if pos in invalid_tiles:
			continue

		add_wood(pos)

func add_wood(pos : Vector2i):
	var wood := Entity.new()
	var wood_pos := PositionComponent.new()
	wood_pos.grid_pos = pos
	wood.add_component(wood_pos)
	wood.add_component(ResourceComponent.new())
	wood.entity_type = Entity.Entity_type.RESOURCE
	element_layer.set_cell(pos, 0, wood_tile)
	city_comp.astar.set_point_solid(pos, true)
	entities.append(wood)

func check_wood() -> void:
	for entity in entities:
		if entity.has_component(ResourceComponent):
			return
	add_wood_random(10)

func get_entity_tiles() -> Array[Vector2i]:
	var entity_tiles : Array[Vector2i] = []
	for entity in entities:
		entity_tiles.append(entity.get_component(PositionComponent).grid_pos)
	return entity_tiles
