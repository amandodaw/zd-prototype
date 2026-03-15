extends Entity

@onready var build_bar : ProgressBar = $ProgressBar

#var build_order : Vector2i = INVALID
#var build_type : String = ""
#var make_order : int = -1

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

var current_job : CityComponent.Tasks = CityComponent.Tasks.IDLE
var check_job_count : float = 0.0
var check_job_timer : float = 2.0


func _process(delta: float) -> void:
	check_job(delta)
	match current_job:
		city_comp.Tasks.BUILD:
			build(delta)
		city_comp.Tasks.MAKE:
			pass
		city_comp.Tasks.GATHER_RESOURCES:
			gather(delta)
		


# ------------------------------------------------
# JOB SYSTEM
# ------------------------------------------------

func check_job(delta : float):

	if  check_job_count >= check_job_timer:
		check_job_count = 0

		if city_comp.tasks[city_comp.Tasks.BUILD]:
			current_job = city_comp.Tasks.BUILD
			return
		if city_comp.tasks[city_comp.Tasks.MAKE]:
			current_job = city_comp.Tasks.MAKE
			return
		if city_comp.tasks[city_comp.Tasks.GATHER_RESOURCES]:
			current_job = city_comp.Tasks.GATHER_RESOURCES
			return

		reset_job()
		return

	check_job_count += delta

func reset_job() ->void:
	release_target()
	target_pos = INVALID
	current_job = city_comp.Tasks.IDLE

func reserve_target() -> void:
	city_comp.reserved_tiles.set(target_pos, true)

func release_target() -> void:
	if target_pos in city_comp.reserved_tiles:
		city_comp.reserved_tiles.erase(target_pos)
# ------------------------------------------------
# GATHER
# ------------------------------------------------

func gather(delta: float) ->void:
	
	if target_pos == INVALID:
		target_pos = find_nearest("wood")
		if target_pos == INVALID or target_pos in city_comp.reserved_tiles:
			print("no wood to take")
			reset_job()
			return
		reserve_target()
		set_astar_path()
	#print("posicion: ", grid_pos, " adyacente: ", adyacent_target_pos, " target: ", target_pos)
	if grid_pos == adyacent_target_pos:
		elements_map.erase_cell(target_pos)
		city_comp.entities.erase(target_pos)
		city_comp.wood_amount += 5
		reset_job()
		return
	follow_path(delta)

# ------------------------------------------------
# BUILD
# ------------------------------------------------

func build(delta: float) -> void:
	if target_pos == INVALID:
		if not take_build_action():
			print("no build order to take")
			reset_job()
			return
		reserve_target()
		set_astar_path()
	#print("posicion: ", grid_pos, " adyacente: ", adyacent_target_pos, " target: ", target_pos)
	if grid_pos == target_pos:
		print("building brr brr")

	follow_path(delta)

func take_build_action() -> bool:
	for build_order in city_comp.build_orders.keys():
		if build_order not in city_comp.reserved_tiles:
			target_pos = build_order
			adyacent_target_pos = choose_adjacent(build_order)
			return true
	return false

# ------------------------------------------------
# MAKE
# ------------------------------------------------


#---------------------
	#UTILES
#--------------------
