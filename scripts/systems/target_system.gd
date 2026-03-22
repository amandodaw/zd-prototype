class_name TargetSystem

func update(delta : float, entities :  Array[Entity]):
	for entity in entities:
		var ai_comp : AIComponent = entity.get_component(AIComponent)
		var target_comp : TargetComponent = entity.get_component(TargetComponent)
		var plan_comp : PlanComponent = entity.get_component(PlanComponent)
		match ai_comp.current_job:
			CityComponent.Tasks.BUILD:
				if plan_comp.current_action == null:
					if !take_build_action(entity):
						ai_comp.current_job = CityComponent.Tasks.IDLE
			CityComponent.Tasks.MAKE:
				pass
			CityComponent.Tasks.GATHER_RESOURCES:
				#El siguiente if debería ser también current_action == null como build?
				if target_comp.target_pos == GridUtils.INVALID:
					if !find_wood(entity):
						ai_comp.current_job = CityComponent.Tasks.IDLE

func find_wood(entity : Entity):
	var city_comp : CityComponent = entity.get_component(AIComponent).city_comp
	var target_comp : TargetComponent = entity.get_component(TargetComponent)
	target_comp.target_pos = find_nearest(entity, "wood")
	if target_comp.target_pos == GridUtils.INVALID or target_comp.target_pos in city_comp.reserved_tiles:
		print("could not find wood")
		return false
	print("wood encontrada! SI!: ", target_comp.target_pos)
	reserve_target(entity)
	return true
	

func take_build_action(entity : Entity) -> bool:
	var city_comp : CityComponent = entity.get_component(AIComponent).city_comp
	for build_order_pos in city_comp.build_orders.keys():
		var build_order : BuildOrderComponent = city_comp.build_orders.get(build_order_pos)
		if build_order.state == BuildOrderComponent.State.FREE:
			if city_comp.wood_amount < build_order.cost:
				print("not enough wood")
				return false
			city_comp.wood_amount -= build_order.cost
			
			build_order.state = BuildOrderComponent.State.RESERVED
			build_order.worker = entity
			
			entity.get_component(TargetComponent).target_pos = build_order_pos
			entity.get_component(TargetComponent).adyacent_target_pos = entity.choose_adjacent(build_order_pos)
			
			#city_comp.build_orders.erase(build_order_pos)
			reserve_target(entity)
			#set_astar_path()
			return true
			
	print("no build order to take")
	return false


func reserve_target(entity : Entity) -> void:
	var city_comp = entity.get_component(AIComponent).city_comp
	city_comp.reserved_tiles.set(entity.get_component(TargetComponent).target_pos, true)

func release_target(entity : Entity) -> void:
	var city_comp = entity.get_component(AIComponent).city_comp
	if entity.get_component(TargetComponent).target_pos in city_comp.reserved_tiles:
		city_comp.reserved_tiles.erase(entity.get_component(TargetComponent).target_pos)

func find_nearest(entity : Entity, type:String) -> Vector2i:
	var city_comp = entity.get_component(AIComponent).city_comp

	var best := GridUtils.INVALID
	var best_dist := 999999

	for tile in city_comp.entities:

		if city_comp.entities[tile] != type:
			continue
			
		if tile in city_comp.reserved_tiles:
			continue

		var dist = abs(tile.x - entity.get_component(PositionComponent).grid_pos.x) + abs(tile.y - entity.get_component(PositionComponent).grid_pos.y)

		if dist < best_dist:
			best_dist = dist
			best = tile

	return best

func find_nearest_alive(entity: Entity, type:String) -> Vector2i:
	var city_comp = entity.get_component(AIComponent).city_comp

	var best := GridUtils.INVALID
	var best_dist := 999999
	
	for tile in city_comp.living_entities.keys():
		if !is_instance_valid(city_comp.living_entities[tile]) or city_comp.living_entities[tile].entity_type != type:
			continue
		var dist = abs(tile.x - entity.get_component(PositionComponent).grid_pos.x) + abs(tile.y - entity.get_component(PositionComponent).grid_pos.y)

		if dist < best_dist:
			best_dist = dist
			best = tile

	return best

func is_adjacent(a: Vector2i, b: Vector2i) -> bool:
	var dx = abs(a.x - b.x)
	var dy = abs(a.y - b.y)
	return max(dx, dy) == 1

func choose_adjacent(entity : Entity, target: Vector2i) -> Vector2i:
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
		if not is_cell_walkable(entity, candidate):
			continue
		
		# distancia desde el humano
		var dist = abs(candidate.x - entity.get_component(PositionComponent).grid_pos.x) + abs(candidate.y - entity.get_component(PositionComponent).grid_pos.y)
		
		if dist < best_dist:
			best_dist = dist
			best_pos = candidate
	
	return best_pos

func is_cell_walkable(entity: Entity, cell: Vector2i) -> bool:
	var city_comp = entity.get_component(AIComponent).city_comp
	if city_comp.astar.is_point_solid(cell):
		return false
	if cell in city_comp.reserved_tiles:
		return false
	return true

func check_target_in_range(entity: Entity, range : int) -> bool:
	var city_comp = entity.get_component(AIComponent).city_comp
	if abs(entity.get_component(TargetComponent).target_pos.x - entity.get_component(PositionComponent).grid_pos.x) + abs(entity.get_component(TargetComponent).target_pos.y - entity.get_component(PositionComponent).grid_pos.y) <= range:
		return true
	return false
