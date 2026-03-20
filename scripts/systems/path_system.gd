class_name PathSystem

var astar : AStarGrid2D

func update(delta : float, entities : Array[Entity]):
	for entity in entities:
		set_astar_path(entity)
		print(entity.get_component(PathComponent).path)

# ------------------------------------------------
# PATH
# ------------------------------------------------

func set_astar_path(entity : Entity) ->void:
	var choosed_pos = entity.get_component(TargetComponent).target_pos
	var path_comp : PathComponent = entity.get_component(PathComponent)
	#var city_comp = entity.get_component(AIComponent).city_comp
	if !astar.is_in_bounds(choosed_pos.x, choosed_pos.y):
		return
	if astar.is_point_solid(entity.get_component(TargetComponent).target_pos):
		entity.get_component(TargetComponent).adyacent_target_pos =  choose_adjacent(entity)
		choosed_pos = entity.get_component(TargetComponent).adyacent_target_pos
	if choosed_pos == GridUtils.INVALID:
		print("no path to take")
		return
	
	path_comp.path = astar.get_id_path(entity.get_component(PositionComponent).grid_pos, choosed_pos)

func choose_adjacent(entity : Entity) -> Vector2i:
	var target : Vector2i = entity.get_component(TargetComponent).target_pos

	var best_pos = GridUtils.INVALID
	var best_dist = INF
	
	var directions = [
		Vector2i(0, -1), # arriba
		Vector2i(0, 1),  # abajo
		Vector2i(-1, 0), # izquierda
		Vector2i(1, 0)   # derecha
	]
	
	for dir in directions:
		var candidate = target + dir
		
		# comprobar si es válida
		if not is_cell_walkable(candidate):
			continue
		
		# distancia desde el humano
		var dist = abs(candidate.x - entity.get_component(PositionComponent).grid_pos.x) + abs(candidate.y - entity.get_component(PositionComponent).grid_pos.y)
		
		if dist < best_dist:
			best_dist = dist
			best_pos = candidate
	
	return best_pos

func is_cell_walkable(cell: Vector2i) -> bool:
	if astar.is_point_solid(cell):
		return false
	#if cell in city_comp.reserved_tiles:
		#return false
	return true
