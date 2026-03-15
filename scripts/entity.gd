extends Sprite2D
class_name Entity

const INVALID := Vector2i(-1,-1)

var grid_pos : Vector2i = Vector2i.ZERO
var target_pos : Vector2i = INVALID

var speed := 0.1
var speed_cont := 0.0

var elements_map : TileMapLayer
var city_comp : CityComponent

var entity_type : String

var last_pos : Vector2i = INVALID

var path : Array[Vector2i]
var path_index = 0

# ------------------------------------------------
# PATH
# ------------------------------------------------

func set_path():

	path = city_comp.astar.get_id_path(grid_pos, target_pos)

	if path.size() > 0:
		path.remove_at(0)

	path_index = 0

func clear_path():
	path.clear()
	path_index = 0


func follow_path(delta):

	if path.is_empty():
		set_path()
		return

	if path_index >= path.size():
		set_path()
		return

	var next_cell = path[path_index]

	if grid_pos == next_cell:
		path_index += 1
		return

	move_to_cell(next_cell, delta)


func move_to_cell(cell:Vector2i, delta):

	if speed_cont < speed:
		speed_cont += delta
		return

	var dx = cell.x - grid_pos.x
	var dy = cell.y - grid_pos.y

	var dir

	if abs(dx) > abs(dy):
		dir = GridUtils.direction.RIGHT if dx < 0 else GridUtils.direction.LEFT
	else:
		dir = GridUtils.direction.DOWN if dy > 0 else GridUtils.direction.UP

	var old_pos = grid_pos

	if try_move(dir):
		speed_cont = 0
		return

	# si no se mueve -> recalcular path
	if grid_pos == old_pos:
		set_path()

	speed_cont = 0

# ------------------------------------------------
# MOVEMENT
# ------------------------------------------------

#func move_to(dir):
#
	#var target_cell = grid_pos + GridUtils.DIR[dir]
	#if target_cell in city_comp.entities:
		#print("celda ocupada")
		#return
	#grid_pos = target_cell
	#position = grid_pos * GridUtils.TILE_SIZE
	##city_comp.entities[elements_map.local_to_map(pos)] = "human"

func try_move(dir) -> bool:

	var target_cell = grid_pos + GridUtils.DIR[dir]

	if target_cell in city_comp.entities:
		return false

	if target_cell == last_pos:
		return false

	city_comp.entities.erase(grid_pos)
	last_pos = grid_pos
	grid_pos = target_cell
	position = grid_pos * GridUtils.TILE_SIZE
	city_comp.entities.set(grid_pos, entity_type)
	city_comp.astar.set_point_solid(grid_pos, false)
	city_comp.astar.set_point_solid(target_cell, true)


	return true
#
#func move_to_target(delta):
#
	#if speed_cont < speed:
		#speed_cont += delta
		#return
#
	#if is_adjacent(grid_pos, target_pos):
		#return
#
	#var dx = target_pos.x - grid_pos.x
	#var dy = target_pos.y - grid_pos.y
#
	#var dir_primary
	#var dir_secondary
#
	#if abs(dx) >= abs(dy):
		#dir_primary = GridUtils.direction.RIGHT if dx < 0 else GridUtils.direction.LEFT
		#dir_secondary = GridUtils.direction.DOWN if dy > 0 else GridUtils.direction.UP
	#else:
		#dir_primary = GridUtils.direction.DOWN if dy > 0 else GridUtils.direction.UP
		#dir_secondary = GridUtils.direction.RIGHT if dx < 0 else GridUtils.direction.LEFT
#
	## intentar dirección principal
	#if try_move(dir_primary):
		#speed_cont = 0
		#return
#
	## intentar secundaria
	#if try_move(dir_secondary):
		#speed_cont = 0
		#return
#
	#var dirs = [
		#GridUtils.direction.UP,
		#GridUtils.direction.DOWN,
		#GridUtils.direction.LEFT,
		#GridUtils.direction.RIGHT
	#]
#
	#dirs.shuffle()
#
	#for dir in dirs:
		#if try_move(dir):
			#speed_cont = 0
			#return
#
	#speed_cont = 0

#func move_to_target(delta):
#
	#if speed_cont < speed:
		#speed_cont += delta
		#return
#
	#if is_adjacent(grid_pos, target_pos):
		#return
#
	#var dx = target_pos.x - grid_pos.x
	#var dy = target_pos.y - grid_pos.y
#
	#var dir_primary
	#var dir_secondary
#
	#if abs(dx) >= abs(dy):
		#dir_primary = GridUtils.direction.LEFT if dx > 0 else GridUtils.direction.RIGHT
		#dir_secondary = GridUtils.direction.DOWN if dy > 0 else GridUtils.direction.UP
	#else:
		#dir_primary = GridUtils.direction.DOWN if dy > 0 else GridUtils.direction.UP
		#dir_secondary = GridUtils.direction.LEFT if dx > 0 else GridUtils.direction.RIGHT
#
	#if !try_move(dir_primary):
		#try_move(dir_secondary)
#
	#speed_cont = 0

# ------------------------------------------------
# SEARCH
# ------------------------------------------------

func find_nearest(type:String) -> Vector2i:

	var best := INVALID
	var best_dist := 999999

	for tile in city_comp.entities:

		if city_comp.entities[tile] != type:
			continue

		var dist = abs(tile.x - grid_pos.x) + abs(tile.y - grid_pos.y)

		if dist < best_dist:
			best_dist = dist
			best = tile

	return best


func is_adjacent(a: Vector2i, b: Vector2i) -> bool:
	var dx = abs(a.x - b.x)
	var dy = abs(a.y - b.y)
	return dx + dy == 1
