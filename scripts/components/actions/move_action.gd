class_name MoveAction
extends Action

var has_reserved : bool = false

func execute(entity : Entity, delta : float):
	if finished:
		return
	follow_path(entity, delta)


func follow_path(entity : Entity, delta : float) -> void:
	var path_comp = entity.get_component(PathComponent)
	var move_comp = entity.get_component(MoveComponent)
	var pos_comp = entity.get_component(PositionComponent)
	var target_comp = entity.get_component(TargetComponent)
	var plan_comp: PlanComponent = entity.get_component(PlanComponent)

	if path_comp.needs_repath:
		plan_comp.needs_replan = true
		return

	#Reservar el tile al que se va a mover
	if not has_reserved:
		if !try_reserve(entity):
			fail(entity)
			return

	#Si ha terminado de moverse pero no está adyacente al objetivo, fallar el movimiento
	if path_comp.path.is_empty():
		if !GridUtils.is_adjacent(target_comp.target_pos, pos_comp.grid_pos):
			print("ya no tengo path...")
			fail(entity)
		
		finished = true
		return

	#Si ha llegado, pasar al siguiente punto del path
	if pos_comp.grid_pos == path_comp.path[0]:
		path_comp.path.pop_at(0)
		if path_comp.path.is_empty():
			finished = true
			return

	#Dependiendo de la velocidad del move_component de la entidad (Aquí se mueve realmente)
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

	#Si la celda está ocupada por otra entidad, esperar a que se libere
	if ai_comp.city_comp.living_entities.has(next_pos):
		return

	ai_comp.city_comp.living_entities.erase(pos_comp.grid_pos)
	pos_comp.grid_pos = next_pos
	entity.position = next_pos * GridUtils.TILE_SIZE

	ai_comp.city_comp.living_entities.set(next_pos, entity)

func on_cancel(entity : Entity) -> void:
	var path_comp : PathComponent = entity.get_component(PathComponent)
	var target_comp : TargetComponent = entity.get_component(TargetComponent)
	
	release_reservation(entity)
	path_comp.path.clear()
	target_comp.target_pos = GridUtils.INVALID

func on_finished(entity : Entity) -> void:
	release_reservation(entity)

func fail(entity: Entity) -> void:
		var plan_comp : PlanComponent = entity.get_component(PlanComponent)
		plan_comp.plan.clear()
		plan_comp.needs_replan = true
		plan_comp.current_action = null

func try_reserve(entity: Entity) -> bool:
	var city_comp = entity.get_component(AIComponent).city_comp
	var target_comp = entity.get_component(TargetComponent)

	# ya reservado por otro
	if city_comp.reserved_tiles.has(target_comp.target_pos):
		return false

	city_comp.reserved_tiles[target_comp.target_pos] = entity
	has_reserved = true
	return true

func release_reservation(entity):
	if not has_reserved:
		return

	var city_comp = entity.get_component(AIComponent).city_comp
	var target_comp = entity.get_component(TargetComponent)

	if city_comp.reserved_tiles.get(target_comp.target_pos) == entity:
		city_comp.reserved_tiles.erase(target_comp.target_pos)

	has_reserved = false
