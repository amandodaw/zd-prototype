class_name BuildAction
extends Action

func execute(entity : Entity, delta : float):
	build(entity, delta)

func build(entity: Entity, delta: float) -> void:
	var city_comp = entity.get_component(AIComponent).city_comp
	var build_order : BuildOrderComponent = city_comp.build_orders.get(entity.get_component(TargetComponent).target_pos)

	if finished:
		return
	if !city_comp.tasks[city_comp.Tasks.BUILD]:
		print("cancelando,", delta)
		city_comp.wood_amount += build_order.cost
		finish_build(entity)
		return
	
	if entity.get_component(PositionComponent).grid_pos == entity.get_component(TargetComponent).adyacent_target_pos:
		entity.build_bar.visible = true
		entity.build_bar.value = build_order.progress * 10

		if build_order.progress >= build_order.needed:
			build_order.progress = 0
			place_building(entity, build_order)
			city_comp.build_orders.erase(entity.get_component(TargetComponent).target_pos)
			finish_build(entity)
			return
		build_order.progress += delta
		return

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

func finish_build(entity: Entity):
	entity.get_component(AIComponent).current_job = CityComponent.Tasks.IDLE
	entity.get_component(AIComponent).city_comp.reserved_tiles.erase(entity.get_component(TargetComponent).target_pos)
	entity.get_component(TargetComponent).target_pos = GridUtils.INVALID
	finished = true
	entity.build_bar.visible = false
