class_name BuildAction
extends Action

func execute(entity: Entity, delta: float):
	var city_comp = entity.get_component(AIComponent).city_comp
	var build_order : BuildOrderComponent = city_comp.build_orders.get(entity.get_component(TargetComponent).target_pos)
	
	#Si ha terminado, no hacer nada
	if finished:
		return
	#Si se ha cancelado la tarea de construccion, cancelar
	if !city_comp.tasks[city_comp.Tasks.BUILD]:
		cancel_build(entity, build_order)
		return
	#Si se encuentra en el lugar, construir
	if entity.get_component(PositionComponent).grid_pos == entity.get_component(TargetComponent).adyacent_target_pos:
		build_order.state = BuildOrderComponent.State.IN_PROGRESS
		entity.build_bar.visible = true
		entity.build_bar.value = build_order.progress * 10

		if build_order.progress >= build_order.needed:
			finish_build(entity, build_order)
			return
		build_order.progress += delta
		return
	#Si no se encuentra en el lugar, cancelar y reconstonstruir plan en ai?
	#Se debería hacer automático con finish_build... 

func place_building(entity : Entity, build_order : BuildOrderComponent) -> void:
	var city_comp = entity.get_component(AIComponent).city_comp
	for offset in build_order.form:
		var target_cell = entity.get_component(TargetComponent).target_pos + offset
		var atlas_coords = build_order.origin + offset

		entity.elements_map.set_cell(target_cell, 0, atlas_coords)
		if offset == Vector2i(2, 2):
			#poner donde van los humanos a crear cosas. donde "ven el workshop"
			city_comp.entities.set(target_cell, "workplace")
			city_comp.astar.set_point_solid(target_cell, false)

func stop_building(entity: Entity):
	entity.get_component(AIComponent).current_job = CityComponent.Tasks.IDLE
	entity.get_component(TargetComponent).target_pos = GridUtils.INVALID
	finished = true
	entity.build_bar.visible = false
	print(entity.get_component(AIComponent).city_comp.build_orders)

func cancel_build(entity: Entity, build_order : BuildOrderComponent) ->void:
	var city_comp = entity.get_component(AIComponent).city_comp
	
	city_comp.wood_amount += build_order.cost
	build_order.state = build_order.State.FREE
	build_order.worker = null
	stop_building(entity)

func finish_build(entity: Entity, build_order : BuildOrderComponent) ->void:
	var city_comp = entity.get_component(AIComponent).city_comp
	
	build_order.progress = 0
	place_building(entity, build_order)
	build_order.state = BuildOrderComponent.State.DONE
	city_comp.build_orders.erase(entity.get_component(TargetComponent).target_pos)
	stop_building(entity)
