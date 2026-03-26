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
