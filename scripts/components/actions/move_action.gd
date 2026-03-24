class_name MoveAction
extends Action

func execute(entity : Entity, delta : float):
	if finished:
		return
	follow_path(entity, delta)


func follow_path(entity : Entity, delta : float) -> void:
	var path_comp = entity.get_component(PathComponent)
	var move_comp = entity.get_component(MoveComponent)
	var pos_comp = entity.get_component(PositionComponent)

	if path_comp.needs_repath:
		return

	if path_comp.path.is_empty():
		finished = true
		return

	#saltar nodo actual si coincide
	if pos_comp.grid_pos == path_comp.path[0]:
		path_comp.path.pop_at(0)
		if path_comp.path.is_empty():
			finished = true
			return

	if move_comp.speed_cont >= move_comp.speed:
		move_comp.speed_cont = 0
		move_to_path_point(entity)
		return 

	move_comp.speed_cont += delta

func move_to_path_point(entity : Entity):
	var path_comp = entity.get_component(PathComponent)
	var pos_comp = entity.get_component(PositionComponent)
	var ai_comp = entity.get_component(AIComponent)

	var next_pos = path_comp.path.pop_at(0)

	ai_comp.city_comp.living_entities.erase(pos_comp.grid_pos)

	pos_comp.grid_pos = next_pos
	entity.position = next_pos * GridUtils.TILE_SIZE

	ai_comp.city_comp.living_entities.set(next_pos, entity)

func on_cancel(entity : Entity) -> void:
	var path_comp : PathComponent = entity.get_component(PathComponent)
	var target_comp : TargetComponent = entity.get_component(TargetComponent)
	
	path_comp.path.clear()
	target_comp.target_pos = GridUtils.INVALID

func on_finished(entity : Entity) -> void:
	var target_comp : TargetComponent = entity.get_component(TargetComponent)
	var plan_comp : PlanComponent = entity.get_component(PlanComponent)
	#if plan_comp.plan.is_empty()
	print("terminé de moverme")
	print("target pos: ", target_comp.target_pos)
	print("mi pos: ", entity.get_component(PositionComponent).grid_pos)

# ------------------------------------------------
# MOVE
	#print("me estoy moviendo!")
	#var path = entity.get_component(PathComponent)
	#var pos = entity.get_component(PositionComponent)
	#print("path: ", path.path)
#
	#if not path or path.path.is_empty():
		#finished = true
		#return
#
	#if path.current_index >= path.path.size():
		#finished = true
		#return
#
	#var next = path.path[path.current_index]
#
	#if pos.grid_pos == next:
		#path.current_index += 1
		#return
#
	#var dir = next - pos.grid_pos
#
	#if dir.x != 0:
		#pos.grid_pos.x += sign(dir.x)
	#elif dir.y != 0:
		#pos.grid_pos.y += sign(dir.y)
# ------------------------------------------------
