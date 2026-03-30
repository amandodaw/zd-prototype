class_name PathSystem

var astar : AStarGrid2D

func update(delta : float, entities : Array[Entity]):
	for entity in entities:
		if !entity.has_component(PathComponent):
			continue
		var path_comp : PathComponent = entity.get_component(PathComponent)
		if path_comp.needs_repath:
			set_astar_path(entity)

# ------------------------------------------------
# PATH
# ------------------------------------------------

func set_astar_path(entity : Entity) ->void:
	var choosed_pos = entity.get_component(TargetComponent).target_pos
	var path_comp : PathComponent = entity.get_component(PathComponent)
	var target_comp : TargetComponent = entity.get_component(TargetComponent)
	var target : Entity = target_comp.target
	var pos_comp : PositionComponent = entity.get_component(PositionComponent)
	var city_comp = entity.get_component(AIComponent).city_comp

	if !astar.is_in_bounds(choosed_pos.x, choosed_pos.y):
		fail_path(entity)
		return

	if astar.is_point_solid(choosed_pos) or (target_comp.target != null and target_comp.target_pos == target_comp.target.get_component(PositionComponent).grid_pos) or city_comp.reserved_tiles.has(choosed_pos):
		choosed_pos = choose_adjacent(entity)
	if choosed_pos == GridUtils.INVALID:
		fail_path(entity)
		print("no path to take")
		
		return

	path_comp.path = astar.get_id_path(pos_comp.grid_pos, choosed_pos)
	path_comp.needs_repath = false
	clear_entity_reservation(entity, city_comp)
	city_comp.reserved_tiles.set(choosed_pos, entity)
	if path_comp.path.is_empty():
		fail_path(entity)
		return

func choose_adjacent(entity : Entity) -> Vector2i:
	var target : Vector2i = entity.get_component(TargetComponent).target_pos
	var city_comp : CityComponent = entity.get_component(AIComponent).city_comp

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
		
		if city_comp.reserved_tiles.has(candidate):
			continue
		
		# distancia desde el humano
		var dist = abs(candidate.x - entity.get_component(PositionComponent).grid_pos.x) + abs(candidate.y - entity.get_component(PositionComponent).grid_pos.y)
		
		if dist < best_dist:
			best_dist = dist
			best_pos = candidate
	
	return best_pos

func is_cell_walkable(cell: Vector2i) -> bool:
	if !astar.is_in_bounds(cell.x, cell.y) or astar.is_point_solid(cell):
		return false
	return true

func fail_path(entity: Entity):
	var path_comp = entity.get_component(PathComponent)
	var plan_comp = entity.get_component(PlanComponent)

	path_comp.path.clear()
	path_comp.needs_repath = false
	plan_comp.needs_replan = true

func clear_entity_reservation(entity, city_comp):
	for cell in city_comp.reserved_tiles.keys():
		if city_comp.reserved_tiles[cell] == entity:
			city_comp.reserved_tiles.erase(cell)
