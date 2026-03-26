class_name HealthSystem

func update(delta : float, entities :  Array[Entity]):
	for entity in entities:
		if !entity.has_component(HealthComponent):
			continue
		var health_comp : HealthComponent = entity.get_component(HealthComponent)
		if health_comp.health <= 0:
			die(entity, entities)

func die(entity : Entity, entities : Array[Entity]) -> void:
	entities.erase(entity)
	entity.queue_free()

func take_damage(entity : Entity, damage_amount : int):
	var health_comp : HealthComponent = entity.get_component(HealthComponent)
	pass
