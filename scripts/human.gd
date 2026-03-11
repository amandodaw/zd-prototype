extends Sprite2D

var target_pos : Vector2i = Vector2i.ZERO
var grid_pos : Vector2i = Vector2i.ZERO

var speed : float = 0.1
var speed_cont : float = 0.0

var visible_tiles : Dictionary

var city_comp: CityComponent

var elements_map : TileMapLayer 

enum jobs {
	IDLE,
	GATHER
}

var current_job : jobs = jobs.IDLE

func move_to(dir : GridUtils.direction) -> void:
	grid_pos += GridUtils.DIR[dir]
	position = grid_pos * GridUtils.TILE_SIZE

func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("mouse_left"): 
		#var mouse_pos = get_global_mouse_position() 
		#target_pos = Vector2i(mouse_pos / GridUtils.TILE_SIZE)
	#move_to_target(delta)
	check_job()
	match current_job:
		jobs.IDLE:
			pass
		jobs.GATHER:
			get_wood(delta)
		

func move_to_target(delta: float) -> void:
	if speed_cont<speed:
		speed_cont += delta
		return
	if grid_pos == target_pos:
		return
	var x_diff = abs(grid_pos.x - target_pos.x)
	var y_diff = abs(grid_pos.y - target_pos.y)
	if x_diff>=y_diff:
		if grid_pos.x < target_pos.x:
			move_to(GridUtils.direction.LEFT)
		if grid_pos.x > target_pos.x:
			move_to(GridUtils.direction.RIGHT)
	if y_diff>=x_diff:
		if grid_pos.y < target_pos.y:
			move_to(GridUtils.direction.DOWN)
		if grid_pos.y > target_pos.y:
			move_to(GridUtils.direction.UP)
	speed_cont = 0

func get_wood(delta: float) -> void:
	if visible_tiles.get(target_pos) != "wood" and visible_tiles.get(target_pos) != "reserved": 
		if get_wood_tiles().is_empty():
			print("No wood to pick HEY")
			return
		target_pos = get_nearest_wood()
		visible_tiles.set(target_pos, "reserved")
	if grid_pos == target_pos and visible_tiles.get(target_pos) == "reserved":
		city_comp.wood_amount += 5
		visible_tiles.erase(target_pos)
		elements_map.erase_cell(target_pos)
		target_pos = Vector2i(-1,-1)
		return
	move_to_target(delta)
	

func get_nearest_wood():

	var nearest_tile : Vector2i
	var nearest_dist = 999999
	if get_wood_tiles().is_empty():
		return grid_pos
	for tile in get_wood_tiles():

		var dist = abs(tile.x - grid_pos.x) + abs(tile.y - grid_pos.y)

		if dist < nearest_dist:
			nearest_dist = dist
			nearest_tile = tile
	
	return nearest_tile

func get_wood_tiles() -> Array[Vector2i] :

	var wood_tiles : Array[Vector2i] = []

	for tile in visible_tiles.keys():
		if visible_tiles[tile] == "wood":
			wood_tiles.append(tile)

	return wood_tiles

func check_job() -> void:
	if city_comp.tasks["gather_resources"]:
		current_job = jobs.GATHER
	else:
		current_job = jobs.IDLE
