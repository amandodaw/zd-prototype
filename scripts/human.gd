extends Entity

@onready var build_bar : ProgressBar = $ProgressBar

var build_order : Vector2i = INVALID
var build_type : String = ""
var make_order : int = -1

var workplace_cost : int = 9
var workplace_build_progress : float = 0.0
var workplace_build_needed : float = 10.0

var workplace_origin : Vector2i = Vector2i(0,4)
var workplace_form : Array[Vector2i] = [
	Vector2i(0,0), Vector2i(1,0), Vector2i(2,0), Vector2i(3,0),
	Vector2i(0,1), Vector2i(1,1), Vector2i(2,1), Vector2i(3,1),
	Vector2i(0,2), Vector2i(1,2), Vector2i(2,2), Vector2i(3,2)	
]

var make_axe_cost : int = 5
var make_axe_progress : float = 0.0
var make_axe_needed : float = 10.0

var wall_cost : int = 5
var wall_progress : float = 0.0
var wall_needed : float = 10.0

var wall_origin : Vector2i = Vector2i(9, 3)
#var wall_form : Array[Vector2i] = [
	#Vector2i(0,0), Vector2i(1,0), Vector2i(2,0), Vector2i(3,0),
	#Vector2i(0,1), Vector2i(1,1), Vector2i(2,1), Vector2i(3,1),
	#Vector2i(0,2), Vector2i(1,2), Vector2i(2,2), Vector2i(3,2)	
#]

enum Jobs {
	IDLE,
	GATHER,
	BUILD,
	MAKE_AXE
}

var current_job : Jobs = Jobs.IDLE


func _process(delta):

	update_job()
	match current_job:
		Jobs.GATHER:
			gather(delta)

		Jobs.BUILD:
			build(delta)
		
		Jobs.MAKE_AXE:
			make(delta)


# ------------------------------------------------
# JOB SYSTEM
# ------------------------------------------------

func update_job():

	if build_order != INVALID:
		return
	
	if current_job != Jobs.IDLE:
		return

	if try_take_build_order():
		current_job = Jobs.BUILD
		return
		
	if try_take_make_order():
		current_job = Jobs.MAKE_AXE
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
			if city_comp.wood_amount < workplace_cost:
				print("not enough wood")
				return false
			release_target()
			target_pos = pos
			set_path()
			build_order = pos
			build_type = "workplace"
			city_comp.build_orders[pos] = "reserved"
			city_comp.wood_amount -= workplace_cost
			return true

		if city_comp.build_orders[pos] == "wall_order":
			if city_comp.wood_amount < wall_cost:
				print("not enough wood")
				return false
			release_target()
			target_pos = pos
			set_path()
			build_order = pos
			build_type = "wall"
			city_comp.build_orders[pos] = "reserved"
			city_comp.wood_amount -= wall_cost
			return true

	return false

func try_take_make_order() -> bool:
	if city_comp.make_orders.is_empty():
		return false
	var workplace_pos = find_nearest("workplace")
	if workplace_pos==INVALID:
		return false
	for i in range(city_comp.make_orders.size()):
		var make_job = city_comp.make_orders[i]
		if make_job == "make_axe":
			if city_comp.wood_amount < make_axe_cost:
				print("not enough wood")
				return false
			release_target()
			target_pos = find_nearest("workplace")
			set_path()
			make_order = i
			city_comp.make_orders[i] = "reserved"
			city_comp.wood_amount -= make_axe_cost
			return true

	return false

func reset_jobs() ->void:
	current_job = Jobs.IDLE
	clear_path()
	update_job()

# ------------------------------------------------
# GATHER
# ------------------------------------------------

func gather(delta):

	if target_pos == INVALID:

		var wood = find_nearest("wood")

		if wood == INVALID:
			reset_jobs()
			return

		target_pos = wood
		set_path()
		city_comp.entities[target_pos] = "reserved"


	if target_pos != INVALID:
		if !city_comp.entities.has(target_pos):
			reset_jobs()
			target_pos = INVALID
			clear_path()
			return


	if is_adjacent(grid_pos, target_pos):

		city_comp.wood_amount += 5
		city_comp.entities.erase(target_pos)
		elements_map.erase_cell(target_pos)
		city_comp.astar.set_point_solid(target_pos, false)

		clear_path()
		reset_jobs()
		target_pos = INVALID
		return


	follow_path(delta)



# ------------------------------------------------
# BUILD
# ------------------------------------------------

func build(delta):

	if is_adjacent(grid_pos, target_pos):

		build_bar.visible = true

		if build_type == "workplace":

			build_bar.value = workplace_build_progress * 10

			if workplace_build_progress >= workplace_build_needed:
				workplace_build_progress = 0
				place_workplace()
				city_comp.build_orders[target_pos] = "workplace"
				finish_build()
				return

			workplace_build_progress += delta
			return


		if build_type == "wall":

			build_bar.value = wall_progress * 10

			if wall_progress >= wall_needed:
				wall_progress = 0
				place_wall()
				city_comp.build_orders[target_pos] = "wall"
				finish_build()
				return

			wall_progress += delta
			return

	follow_path(delta)

func place_workplace() -> void:
	for offset in workplace_form:
		var target_cell = build_order + offset
		var atlas_coords = workplace_origin + offset
		if offset == Vector2i(2, 2):
			#poner donde van los humanos a crear cosas. donde "ven el workshop"
			city_comp.entities.set(target_cell, "workplace")
		elements_map.set_cell(target_cell, 0, atlas_coords)
		city_comp.astar.set_point_solid(target_cell, true)

func place_wall() -> void:

	var target_cell = build_order
	var atlas_coords = wall_origin

	city_comp.entities.set(target_cell, "wall")
	elements_map.set_cell(target_cell, 0, atlas_coords)
	city_comp.astar.set_point_solid(target_cell, true)
		

func finish_build():

	release_target()
	target_pos = INVALID
	build_order = INVALID
	build_type = ""
	build_bar.visible = false
	reset_jobs()

# ------------------------------------------------
# MAKE
# ------------------------------------------------

func make(delta):
	if is_adjacent(grid_pos, target_pos):
		build_bar.visible = true
		build_bar.value = make_axe_progress*10
		if make_axe_progress>=make_axe_needed:
			make_axe_progress = 0
			city_comp.axe_amount += 1
			city_comp.make_orders.pop_at(make_order)
			release_target()
			target_pos = INVALID
			build_order = INVALID
			build_bar.visible = false
			make_order = -1
			reset_jobs()
			return
		make_axe_progress += delta
		return

	follow_path(delta)

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
		if city_comp.entities.get(target_pos) == "reserved":
			city_comp.entities[target_pos] = state
			if current_job == Jobs.BUILD:
				city_comp.wood_amount -= workplace_cost
	target_pos = INVALID
	clear_path()
