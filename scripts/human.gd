extends Sprite2D

var target_pos : Vector2i = Vector2i.ZERO
var grid_pos : Vector2i = Vector2i.ZERO

var speed : float = 0.1
var speed_cont : float = 0.0

var visible_tiles : Dictionary

var city_comp: CityComponent

var elements_map : TileMapLayer 

var workshop_origin : Vector2i = Vector2i(0,4)
var workshop_form : Array[Vector2i] = [
	Vector2i(0,0), Vector2i(1,0), Vector2i(2,0), Vector2i(3,0),
	Vector2i(0,1), Vector2i(1,1), Vector2i(2,1), Vector2i(3,1),
	Vector2i(0,2), Vector2i(1,2), Vector2i(2,2), Vector2i(3,2)	
]

enum jobs {
	IDLE,
	GATHER,
	BUILD
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
		jobs.BUILD:
			build(delta)
		

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

	# prioridad 1: build
	if check_build_orders():
		return

	# prioridad 2: gather
	if city_comp.tasks["gather_resources"]:
		current_job = jobs.GATHER
		return

	# fallback
	current_job = jobs.IDLE

func check_build_orders() -> bool:
	if current_job == jobs.BUILD:
		return false
	for build_order_pos in city_comp.build_orders.keys():

		if city_comp.build_orders.get(build_order_pos) == "workplace":
			print("nono")
			target_pos = build_order_pos
			city_comp.build_orders[build_order_pos] = "reserved"
			current_job = jobs.BUILD
			return true

	return false

func build(delta: float) -> void:
	move_to_target(delta)
	if grid_pos==target_pos:
		print("buildingbip")


func build_workplace() -> void:
	var mouse_world = elements_map.get_global_mouse_position()
	var base_cell = elements_map.local_to_map(elements_map.to_local(mouse_world))
	for offset in workshop_form:
		var target_cell = base_cell + offset
		var atlas_coords = workshop_origin + offset
		elements_map.set_cell(target_cell, 0, atlas_coords)
