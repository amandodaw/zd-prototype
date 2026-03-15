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
	grid_pos = path[0]
	position = grid_pos*GridUtils.TILE_SIZE

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


func is_adjacent(a: Vector2i, b: Vector2i) -> bool:
	var dx = abs(a.x - b.x)
	var dy = abs(a.y - b.y)
	return max(dx, dy) == 1

func choose_adjacent(pos: Vector2i) -> Vector2i:
	for dir in GridUtils.DIR:
		var new_target_cell = pos + dir
		if city_comp.astar.is_in_boundsv(new_target_cell) and !city_comp.astar.is_point_solid(new_target_cell):
			return new_target_cell
	return INVALID
