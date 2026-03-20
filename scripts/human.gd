extends Entity

@onready var build_bar : ProgressBar = $ProgressBar

#var build_order : Vector2i = INVALID
#var build_type : String = ""
#var make_order : int = -1

var current_job : CityComponent.Tasks = CityComponent.Tasks.IDLE
var check_job_count : float = 0.0
var check_job_timer : float = 2.0


func _process(delta: float) -> void:
	#check_job(delta)
	match get_component(AIComponent).current_job:
		city_comp.Tasks.BUILD:
			build(delta)
		city_comp.Tasks.MAKE:
			#make(delta)
			pass
		city_comp.Tasks.GATHER_RESOURCES:
			gather(delta)
		


# ------------------------------------------------
# JOB SYSTEM
# ------------------------------------------------

#func check_job(delta : float):
#
	#if  check_job_count >= check_job_timer:
		#check_job_count = 0
		#if current_job != city_comp.Tasks.IDLE and city_comp.tasks[current_job]:
			#return
		#if city_comp.tasks[city_comp.Tasks.BUILD] and !city_comp.build_orders.is_empty():
			#if take_build_action():
				#current_job = city_comp.Tasks.BUILD
				#return
		#if city_comp.tasks[city_comp.Tasks.MAKE] and !city_comp.make_orders.is_empty():
			#if take_make_action():
				#current_job = city_comp.Tasks.MAKE
				#return
		#if city_comp.tasks[city_comp.Tasks.GATHER_RESOURCES]:
			#current_job = city_comp.Tasks.GATHER_RESOURCES
			#return
#
		#reset_job()
		#return
#
	#check_job_count += delta
#
#func reset_job() ->void:
	#release_target()
	#target_pos = GridUtils.INVALID
	#current_job = city_comp.Tasks.IDLE
	#path.clear()

func reset_job() ->void:
	release_target()
	get_component(TargetComponent).target_pos = GridUtils.INVALID
	current_job = city_comp.Tasks.IDLE
	path.clear()

# ------------------------------------------------
# GATHER
# ------------------------------------------------

func gather(delta: float) ->void:

	if get_component(TargetComponent).target_pos != GridUtils.INVALID and !city_comp.entities.has(get_component(TargetComponent).target_pos):
		reset_job()
		return

	if get_component(TargetComponent).target_pos == GridUtils.INVALID:
		get_component(TargetComponent).target_pos = find_nearest("wood")
		if get_component(TargetComponent).target_pos == GridUtils.INVALID or get_component(TargetComponent).target_pos in city_comp.reserved_tiles:
			print("no wood to take")
			reset_job()
			return
		reserve_target()
		set_astar_path()

	if get_component(PositionComponent).grid_pos == get_component(TargetComponent).adyacent_target_pos:
		elements_map.erase_cell(get_component(TargetComponent).target_pos)
		city_comp.entities.erase(get_component(TargetComponent).target_pos)
		city_comp.astar.set_point_solid(get_component(TargetComponent).target_pos, false)
		city_comp.wood_amount += 5
		reset_job()
		return

	follow_path(delta)

# ------------------------------------------------
# BUILD
# ------------------------------------------------

func build(delta: float) -> void:
	var build_order : BuildOrderComponent = city_comp.build_orders.get(get_component(TargetComponent).target_pos)

	if !city_comp.tasks[city_comp.Tasks.BUILD]:
		city_comp.wood_amount += build_order.cost
		reset_job()
		return
	
	if get_component(PositionComponent).grid_pos == get_component(TargetComponent).adyacent_target_pos:
		print("jumanji")
		build_bar.visible = true
		
		build_bar.value = build_order.progress * 10

		if build_order.progress >= build_order.needed:
			build_order.progress = 0
			place_building(build_order)
			city_comp.build_orders.erase(get_component(TargetComponent).target_pos)
			finish_build()
			return
		build_order.progress += delta
		return

	follow_path(delta)

func place_building(build_order : BuildOrderComponent) -> void:
	for offset in build_order.form:
		var target_cell = get_component(TargetComponent).target_pos + offset
		var atlas_coords = build_order.origin + offset

		elements_map.set_cell(target_cell, 0, atlas_coords)
		if offset == Vector2i(2, 2):
			#poner donde van los humanos a crear cosas. donde "ven el workshop"
			city_comp.entities.set(target_cell, "workplace")
			city_comp.astar.set_point_solid(target_cell, false)

#func take_build_action() -> bool:
	#for build_order in city_comp.build_orders.keys():
		#if build_order not in city_comp.reserved_tiles:
			#if city_comp.wood_amount < wall_cost:
				#print("not enough wood")
				#return false
			#city_comp.wood_amount -= wall_cost
			#get_component(TargetComponent).target_pos = build_order
			#get_component(TargetComponent).adyacent_target_pos = choose_adjacent(build_order)
			#reserve_target()
			#set_astar_path()
			#return true
			#
	#print("no build order to take")
	#return false
#
#func place_workplace() -> void:
	#for offset in workplace_form:
		#var target_cell = get_component(TargetComponent).target_pos + offset
		#var atlas_coords = workplace_origin + offset
#
		#elements_map.set_cell(target_cell, 0, atlas_coords)
		#if offset == Vector2i(2, 2):
			##poner donde van los humanos a crear cosas. donde "ven el workshop"
			#city_comp.entities.set(target_cell, "workplace")
			#continue
		#city_comp.astar.set_point_solid(target_cell, true)
#
#func place_wall() -> void:
#
	#var target_cell = get_component(TargetComponent).target_pos
	#var atlas_coords = wall_origin
#
	#city_comp.entities.set(target_cell, "wall")
	#elements_map.set_cell(target_cell, 0, atlas_coords)
	#city_comp.astar.set_point_solid(target_cell, true)
	#var wall = Wall.new()
	#city_comp.living_entities.set(target_cell, wall)
	#wall.entity_type = "wall"
	#wall.grid_pos = target_cell
	#wall.city_comp = city_comp
	#wall.elements_map = elements_map
	

func finish_build():
	
	reset_job()
	build_bar.visible = false


# ------------------------------------------------
# MAKE
# ------------------------------------------------

#func make(delta: float) -> void:
	#
	#if !city_comp.tasks[city_comp.Tasks.MAKE]:
		#city_comp.wood_amount += make_axe_cost
		#reset_job()
		#return
	#
	#if get_component(PositionComponent).grid_pos == get_component(TargetComponent).target_pos:
		#
		#build_bar.visible = true
#
		#build_bar.value = make_axe_progress * 10
#
		#if make_axe_progress >= make_axe_needed:
			#make_axe_progress = 0
			#city_comp.axe_amount += 1
			#finish_build()
			#return
		#make_axe_progress += delta
		#return
#
	#follow_path(delta)
#
#func take_make_action() -> bool:
	#if !city_comp.make_orders.is_empty():
		#for make_order in city_comp.make_orders:
			#if city_comp.wood_amount < make_axe_cost:
				#print("not enough wood")
				#return false
			#get_component(TargetComponent).target_pos = find_nearest("workplace")
			#if get_component(TargetComponent).target_pos == GridUtils.INVALID:
				#print("no workplace available")
				#return false
			#city_comp.make_orders.erase(make_order)
			#city_comp.wood_amount -= make_axe_cost
#
			#reserve_target()
			#set_astar_path()
			#return true
	#print("no make order to take")
	#return false

#---------------------
	#UTILES
#--------------------
