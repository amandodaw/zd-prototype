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

var current_job : CityComponent.Tasks = CityComponent.Tasks.IDLE
var check_job_count : float = 0.0
var check_job_timer : float = 2.0


func _process(delta: float) -> void:
	check_job(delta)
	match current_job:
		city_comp.Tasks.BUILD:
			pass
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
	current_job = city_comp.Tasks.IDLE

# ------------------------------------------------
# GATHER
# ------------------------------------------------

func gather(delta: float) ->void:
	
	if target_pos == INVALID:
		target_pos = find_nearest("wood")
		if target_pos == INVALID:
			print("no wood to take")
			reset_job()
		set_astar_path()
		print(path)
		print(grid_pos, target_pos)
		print(city_comp.astar.is_point_solid(grid_pos), city_comp.astar.is_point_solid(target_pos))
			

# ------------------------------------------------
# BUILD
# ------------------------------------------------


# ------------------------------------------------
# MAKE
# ------------------------------------------------


#---------------------
	#UTILES
#--------------------
