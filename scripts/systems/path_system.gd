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
	#var city_comp = entity.get_component(AIComponent).city_comp

	if !astar.is_in_bounds(choosed_pos.x, choosed_pos.y):
		return
	#Hay que revisar esta condicion. Puede dar problemas con ataques de rango
	#Ya hecho. Si el target es el mismo que el de la posicion del attack target siempre que no sea null, elegir adyacente.
	#Cuando haga ranged attack, elegirá otra posición para atacar
	if astar.is_point_solid(target_comp.target_pos) or (target_comp.target != null and target_comp.target_pos == target_comp.target.get_component(PositionComponent).grid_pos):
		choosed_pos = choose_adjacent(entity)
	if choosed_pos == GridUtils.INVALID:
		print("no path to take")
		return

	path_comp.path = astar.get_id_path(pos_comp.grid_pos, choosed_pos)
	path_comp.needs_repath = false

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
	if !astar.is_in_bounds(cell.x, cell.y) or astar.is_point_solid(cell):
		return false
	return true
