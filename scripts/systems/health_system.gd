class_name HealthSystem

func update(delta : float, entities :  Array[Entity]):
	for entity in entities:
		var health_comp : HealthComponent = entity.get_component(HealthComponent)
		if health_comp.health <= 0:
			die(entity, entities)

func die(entity : Entity, entities : Array[Entity]) -> void:
	var health_comp : HealthComponent = entity.get_component(HealthComponent)
	var target_comp : TargetComponent = entity.get_component(TargetComponent)
	var city_comp : CityComponent = entity.get_component(AIComponent).city_comp
	
	city_comp.reserved_tiles.erase(target_comp.target_pos)
	entities.erase(entity)
	entity.queue_free()
