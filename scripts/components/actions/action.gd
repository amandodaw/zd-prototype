class_name Action

var finished := false

func execute(entity, delta):
	pass

func is_finished() -> bool:
	return finished

func on_cancel(entity : Entity) -> void:
	pass

func on_finished(entity : Entity) -> void:
	pass

func check_job(entity : Entity, task : CityComponent.Tasks):
	var city_comp : CityComponent = entity.get_component(AIComponent).city_comp
	if city_comp.tasks[task]:
		return true
	return false
