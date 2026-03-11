extends Sprite2D

const INVALID := Vector2i(-1,-1)

var grid_pos : Vector2i = Vector2i.ZERO
var target_pos : Vector2i = INVALID
var build_order : Vector2i = INVALID
var speed := 0.1
var speed_cont := 0.0

var visible_tiles : Dictionary
var city_comp : CityComponent
var elements_map : TileMapLayer

var workplace_origin : Vector2i = Vector2i(0,4)

var workplace_form : Array[Vector2i] = [
	Vector2i(0,0), Vector2i(1,0), Vector2i(2,0), Vector2i(3,0),
	Vector2i(0,1), Vector2i(1,1), Vector2i(2,1), Vector2i(3,1),
	Vector2i(0,2), Vector2i(1,2), Vector2i(2,2), Vector2i(3,2)	
]

enum Jobs {
	IDLE,
	GATHER,
	BUILD
}

var current_job : Jobs = Jobs.IDLE


func _process(delta):

	update_job()
	match current_job:
		Jobs.GATHER:
			gather(delta)

		Jobs.BUILD:
			build(delta)


# ------------------------------------------------
# JOB SYSTEM
# ------------------------------------------------

func update_job():

	if build_order != INVALID:
		return

	if try_take_build_order():
		current_job = Jobs.BUILD
		return

	if city_comp.tasks["gather_resources"]:
		current_job = Jobs.GATHER
		return
	release_target()
	current_job = Jobs.IDLE


func try_take_build_order() -> bool:
	if city_comp.build_orders.is_empty():
		return false

	for pos in city_comp.build_orders.keys():

		if city_comp.build_orders[pos] == "workplace_order":
			release_target()
			target_pos = pos
			build_order = pos
			city_comp.build_orders[pos] = "reserved"
			return true

	return false


# ------------------------------------------------
# GATHER
# ------------------------------------------------

func gather(delta):

	if target_pos == INVALID:

		var wood = find_nearest("wood")

		if wood == INVALID:
			return

		target_pos = wood
		visible_tiles[target_pos] = "reserved"

	if grid_pos == target_pos:

		city_comp.wood_amount += 5
		visible_tiles.erase(target_pos)
		elements_map.erase_cell(target_pos)

		target_pos = INVALID
		return

	move_to_target(delta)


# ------------------------------------------------
# BUILD
# ------------------------------------------------

func build(delta):

	if grid_pos == target_pos:
		place_workplace()
		city_comp.build_orders.set(target_pos, "workplace")
		release_target()
		target_pos = INVALID
		build_order = INVALID
		return

	move_to_target(delta)

func place_workplace() -> void:
	for offset in workplace_form:
		var target_cell = build_order + offset
		var atlas_coords = workplace_origin + offset
		elements_map.set_cell(target_cell, 0, atlas_coords)
# ------------------------------------------------
# MOVEMENT
# ------------------------------------------------

func move_to(dir):

	grid_pos += GridUtils.DIR[dir]
	position = grid_pos * GridUtils.TILE_SIZE


func move_to_target(delta):

	if speed_cont < speed:
		speed_cont += delta
		return

	if grid_pos == target_pos:
		return

	var dx = target_pos.x - grid_pos.x
	var dy = target_pos.y - grid_pos.y

	if abs(dx) >= abs(dy):
		move_to(GridUtils.direction.LEFT if dx > 0 else GridUtils.direction.RIGHT)
	else:
		move_to(GridUtils.direction.DOWN if dy > 0 else GridUtils.direction.UP)

	speed_cont = 0


# ------------------------------------------------
# SEARCH
# ------------------------------------------------

func find_nearest(type:String) -> Vector2i:

	var best := INVALID
	var best_dist := 999999

	for tile in visible_tiles.keys():

		if visible_tiles[tile] != type:
			continue

		var dist = abs(tile.x - grid_pos.x) + abs(tile.y - grid_pos.y)

		if dist < best_dist:
			best_dist = dist
			best = tile

	return best
	
#---------------------
	#UTILES
#--------------------

func release_target():
	var state : String
	match current_job:
		Jobs.GATHER:
			state = "wood"
		Jobs.BUILD:
			state = "workplace_order"
	if target_pos != INVALID:
		if visible_tiles.get(target_pos) == "reserved":
			visible_tiles[target_pos] = state
	target_pos = INVALID
