class_name GatherAction
extends Action

func execute(entity : Entity, delta : float):
	#if get_component(TargetComponent).target_pos != GridUtils.INVALID and !city_comp.entities.has(get_component(TargetComponent).target_pos):
		#reset_job()
		#return
	var target_comp : TargetComponent = entity.get_component(TargetComponent)
	var position_comp : PositionComponent = entity.get_component(PositionComponent)
	var ai_comp : AIComponent = entity.get_component(AIComponent)
	var city_comp : CityComponent = entity.get_component(AIComponent).city_comp

	if !city_comp.tasks[city_comp.Tasks.GATHER_RESOURCES] or ai_comp.current_job!=CityComponent.Tasks.GATHER_RESOURCES:
		cancel_picking(entity)
		return

	if GridUtils.is_adjacent(position_comp.grid_pos, target_comp.target_pos):
		entity.elements_map.erase_cell(target_comp.target_pos)
		city_comp.entities.erase(target_comp.target_pos)
		city_comp.astar.set_point_solid(target_comp.target_pos, false)
		city_comp.wood_amount += 5
		print("HE COGIDO LA MADERA EN: ", target_comp.target.get_component(PositionComponent).grid_pos)
		target_comp.target.get_component(ResourceComponent).state = ResourceComponent.States.PICKED
		stop_picking(entity)
		return

func stop_picking(entity : Entity):
	#var target_comp : TargetComponent = entity.get_component(TargetComponent)
	#target_comp.needs_retarget = true
	finished = true

func cancel_picking(entity : Entity):
	var target_comp : TargetComponent = entity.get_component(TargetComponent)
	var plan_comp : PlanComponent = entity.get_component(PlanComponent)
	plan_comp.plan.clear()
	target_comp.target.get_component(ResourceComponent).state = ResourceComponent.States.FREE
	print("HE CANCELADO COGER LA MADERA EN: ", target_comp.target.get_component(PositionComponent).grid_pos)
	stop_picking(entity)

func on_cancel(entity : Entity) -> void:
	cancel_picking(entity)
