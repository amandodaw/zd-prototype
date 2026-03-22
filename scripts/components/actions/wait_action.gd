class_name WaitAction
extends Action

var time_left := 2.0

func execute(entity: Entity, delta: float):
	time_left -= delta
	
	if time_left <= 0:
		finished = true
