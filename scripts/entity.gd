extends Sprite2D
class_name Entity

const INVALID := Vector2i(-1,-1)

var grid_pos : Vector2i = Vector2i.ZERO
var target_pos : Vector2i = INVALID
var adyacent_target_pos : Vector2i = INVALID

var speed := 0.1
var speed_cont := 0.0

var elements_map : TileMapLayer
var city_comp : CityComponent

var entity_type : String

var path : Array[Vector2i]
var path_index = 0

var health : int = 3
var attack_speed : float = 3.0
var attack_damage : int = 1
var attack_cooldown : float = 0.0

var target : Entity

# ------------------------------------------------
# PATH
# ------------------------------------------------

func set_astar_path() ->void:
	var choosed_pos = target_pos
	if city_comp.astar.is_point_solid(target_pos):
		adyacent_target_pos =  choose_adjacent(target_pos)
		choosed_pos = adyacent_target_pos
	if choosed_pos == INVALID:
		print("no path to take")
		return
	
	path = city_comp.astar.get_id_path(grid_pos, choosed_pos)

func follow_path(delta : float) ->void:
	if path.is_empty():
		return
	if speed_cont>=speed:
		speed_cont=0
		if grid_pos==path[0]: 
			path.pop_at(0)
		move_to_path_point()
		return 
	speed_cont += delta
	
	

# ------------------------------------------------
# MOVE
# ------------------------------------------------

func move_to_path_point():
	if path.is_empty():
		return
	city_comp.living_entities.erase(grid_pos)
	
	grid_pos = path[0]
	position = grid_pos*GridUtils.TILE_SIZE
	
	city_comp.living_entities.set(grid_pos, self)

# ------------------------------------------------
# COMBAT
# ------------------------------------------------

func take_damage(damage_amount : int) -> void:
	health -= damage_amount
	if health==0:
		print("Muerto ", self)


# ------------------------------------------------
# UTILS
# ------------------------------------------------

func find_nearest(type:String) -> Vector2i:

	var best := INVALID
	var best_dist := 999999

	for tile in city_comp.entities:

		if city_comp.entities[tile] != type:
			continue
			
		if tile in city_comp.reserved_tiles:
			continue

		var dist = abs(tile.x - grid_pos.x) + abs(tile.y - grid_pos.y)

		if dist < best_dist:
			best_dist = dist
			best = tile

	return best

func find_nearest_alive(type:String) -> Vector2i:

	var best := INVALID
	var best_dist := 999999
	
	for tile in city_comp.living_entities.keys():
		if city_comp.living_entities[tile].entity_type != type:
			continue
		var dist = abs(tile.x - grid_pos.x) + abs(tile.y - grid_pos.y)

		if dist < best_dist:
			best_dist = dist
			best = tile

	return best

func is_adjacent(a: Vector2i, b: Vector2i) -> bool:
	var dx = abs(a.x - b.x)
	var dy = abs(a.y - b.y)
	return max(dx, dy) == 1

func choose_adjacent(target: Vector2i) -> Vector2i:
	var best_pos = INVALID
	var best_dist = INF
	
	var directions = [
		Vector2i(0, -1), # arriba
		Vector2i(0, 1),  # abajo
		Vector2i(-1, 0), # izquierda
		Vector2i(1, 0)   # derecha
	]
	
	for dir in directions:
		var candidate = target + dir
		
		# comprobar si es válida
		if not is_cell_walkable(candidate):
			continue
		
		# distancia desde el humano
		var dist = abs(candidate.x - grid_pos.x) + abs(candidate.y - grid_pos.y)
		
		if dist < best_dist:
			best_dist = dist
			best_pos = candidate
	
	return best_pos

func is_cell_walkable(cell: Vector2i) -> bool:
	if city_comp.astar.is_point_solid(cell):
		return false
	if cell in city_comp.reserved_tiles:
		return false
	return true

func check_target_in_range(range : int) -> bool:
	if abs(target_pos.x - grid_pos.x) + abs(target_pos.y - grid_pos.y) <= range:
		return true
	return false
