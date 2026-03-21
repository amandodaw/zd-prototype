class_name MoveAction
extends Action

func execute(entity : Entity, delta : float):
		follow_path(entity, delta)

func follow_path(entity : Entity, delta : float) ->void:
	var path_comp = entity.get_component(PathComponent)
	var move_comp = entity.get_component(MoveComponent)
	var target_comp = entity.get_component(TargetComponent)
	print("Target: ", target_comp.target_pos)
	print("Adyacent: ", target_comp.adyacent_target_pos)
	if path_comp.path.is_empty():
		finished = true
		return
	if move_comp.speed_cont>=move_comp.speed:
		move_comp.speed_cont=0
		if entity.get_component(PositionComponent).grid_pos==path_comp.path[0]: 
			path_comp.path.pop_at(0)
		move_to_path_point(entity)
		return 
	move_comp.speed_cont += delta

func move_to_path_point(entity : Entity):
	var path_comp = entity.get_component(PathComponent)
	var ai_comp = entity.get_component(AIComponent)
	if path_comp.path.is_empty():
		finished = true
		return
	ai_comp.city_comp.living_entities.erase(entity.get_component(PositionComponent).grid_pos)
	
	entity.get_component(PositionComponent).grid_pos = path_comp.path[0]
	entity.position = entity.get_component(PositionComponent).grid_pos*GridUtils.TILE_SIZE
	
	ai_comp.city_comp.living_entities.set(entity.get_component(PositionComponent).grid_pos, self)

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
