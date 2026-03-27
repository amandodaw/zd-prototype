class_name TargetSystem

func update(delta : float, entities :  Array[Entity]):
	for entity in entities:
		if !entity.has_component(TargetComponent):
			continue
		var ai_comp : AIComponent = entity.get_component(AIComponent)
		var city_comp : CityComponent = ai_comp.city_comp
		var target_comp : TargetComponent = entity.get_component(TargetComponent)
		var plan_comp : PlanComponent = entity.get_component(PlanComponent)
		
		var old_target : Entity = target_comp.target
		var old_target_pos = target_comp.target_pos
		
		match ai_comp.current_job:

			CityComponent.Tasks.BUILD:

				if has_build_order(entity, city_comp.build_orders):
					if target_comp.target_pos == GridUtils.INVALID:
						restore_build_target(entity)

				elif target_comp.target_pos == GridUtils.INVALID:
					take_build_action(entity)


			CityComponent.Tasks.MAKE:
				pass

			CityComponent.Tasks.GATHER_RESOURCES:
				if target_comp.target == null:
					print("VAMOS A GATHER")
					find_wood(entity, entities)

			CityComponent.Tasks.IDLE:
				if target_comp.target_pos == GridUtils.INVALID:
					target_comp.target_pos = choose_random_adjacent(entity)

			CityComponent.Tasks.ATTACK:
				if target_comp.target == null:
					choose_attack_target(entity, entities, target_comp.target_type)
						
		if old_target != target_comp.target or old_target_pos != target_comp.target_pos:
			print("tengo otro target")
			plan_comp.needs_replan = true


func find_wood(entity : Entity, entities :  Array[Entity]):
	var target_comp : TargetComponent = entity.get_component(TargetComponent)
	var new_target = find_nearest(entity, entities, Entity.Entity_type.RESOURCE)
	if new_target == null:
		print("could not find wood")
		return false
	target_comp.target = new_target
	target_comp.target_pos = new_target.get_component(PositionComponent).grid_pos
	new_target.get_component(ResourceComponent).reserved = true
	print("HE reservado COGER LA MADERA EN: ", target_comp.target.get_component(PositionComponent).grid_pos)
	
	return true

func take_build_action(entity : Entity) -> bool:
	var city_comp : CityComponent = entity.get_component(AIComponent).city_comp
	var target_comp : TargetComponent = entity.get_component(TargetComponent)
	
	for build_order_pos in city_comp.build_orders.keys():
		var build_order : BuildOrderComponent = city_comp.build_orders.get(build_order_pos)
		
		if build_order.state == BuildOrderComponent.State.FREE:
			#Comprobar si hay madera suficiente en la ciudad
			if city_comp.wood_amount < build_order.cost:
				continue

			city_comp.wood_amount -= build_order.cost

			build_order.state = BuildOrderComponent.State.RESERVED
			build_order.worker = entity
			target_comp.target_pos = build_order_pos
			target_comp.target = null

			return true
	#No hay build orders o no hay suficiente madera para ejecutarlas
	print("no build order to take/not enough wood")
	return false

func has_build_order(entity, build_orders):
	for order in build_orders.values():
		if order.worker == entity:
			return true
	return false

func restore_build_target(entity):
	var city_comp = entity.get_component(AIComponent).city_comp
	var target_comp = entity.get_component(TargetComponent)

	for pos in city_comp.build_orders.keys():
		var order = city_comp.build_orders[pos]
		if order.worker == entity:
			target_comp.target_pos = pos
			target_comp.target = null
			return

func find_nearest(entity : Entity, entities :  Array[Entity], target_type : Entity.Entity_type) -> Entity:
	var best : Entity = null
	var best_dist := 999999

	for posible_target in entities:
		if posible_target.entity_type != target_type:
			continue
			
		if target_type == Entity.Entity_type.RESOURCE and posible_target.get_component(ResourceComponent).reserved:
			continue

		var dist = abs(posible_target.get_component(PositionComponent).grid_pos.x - entity.get_component(PositionComponent).grid_pos.x) + abs(posible_target.get_component(PositionComponent).grid_pos.y - entity.get_component(PositionComponent).grid_pos.y)

		if dist < best_dist:
			best_dist = dist
			best = posible_target

	return best

#func find_nearest_alive(entity: Entity, type:String) -> Vector2i:
	#var city_comp = entity.get_component(AIComponent).city_comp
#
	#var best := GridUtils.INVALID
	#var best_dist := 999999
	#
	#for tile in city_comp.living_entities.keys():
		#if !is_instance_valid(city_comp.living_entities[tile]) or city_comp.living_entities[tile].entity_type != type:
			#continue
		#var dist = abs(tile.x - entity.get_component(PositionComponent).grid_pos.x) + abs(tile.y - entity.get_component(PositionComponent).grid_pos.y)
#
		#if dist < best_dist:
			#best_dist = dist
			#best = tile
#
	#return best

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

func choose_random_adjacent(entity: Entity) -> Vector2i:
	var pos_comp : PositionComponent = entity.get_component(PositionComponent)
	var valid_cells: Array[Vector2i] = []

	var directions = [
		Vector2i(0, -1),
		Vector2i(0, 1),
		Vector2i(-1, 0),
		Vector2i(1, 0)
	]

	for dir in directions:
		var candidate = pos_comp.grid_pos + dir
		
		if is_cell_walkable(entity, candidate):
			valid_cells.append(candidate)

	if valid_cells.is_empty():
		return GridUtils.INVALID

	# elegir aleatorio
	return valid_cells[randi() % valid_cells.size()]

func is_cell_walkable(entity: Entity, cell: Vector2i) -> bool:
	var city_comp : CityComponent = entity.get_component(AIComponent).city_comp
	var astar : AStarGrid2D = city_comp.astar
	#Comprobar si existe la celda en el mapa de navegación y si es walkable
	if !astar.is_in_bounds(cell.x, cell.y) or city_comp.astar.is_point_solid(cell):
		return false
	#Comprobar si hay una entidad en esa celda
	if cell in city_comp.living_entities.keys():
		return false
	return true

func check_target_in_range(entity: Entity, range : int) -> bool:
	if abs(entity.get_component(TargetComponent).target_pos.x - entity.get_component(PositionComponent).grid_pos.x) + abs(entity.get_component(TargetComponent).target_pos.y - entity.get_component(PositionComponent).grid_pos.y) <= range:
		return true
	return false

func choose_attack_target(entity: Entity, entities :  Array[Entity], target_type : Entity.Entity_type) -> bool:
	var target_comp : TargetComponent = entity.get_component(TargetComponent)
	for posible_target in entities:
		#Si este ya es mi target, no replanear
		if target_comp.target == posible_target:
			return false
		if posible_target.entity_type == target_type:
			target_comp.target = posible_target
			target_comp.target_pos = posible_target.get_component(PositionComponent).grid_pos
			return true
	return false
