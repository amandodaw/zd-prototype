class_name MoveAction
extends Action

func execute(entity : Entity, delta : float):
	var path = entity.get_component(PathComponent)
	var pos = entity.get_component(PositionComponent)

	if not path or path.path.is_empty():
		finished = true
		return

	if path.current_index >= path.path.size():
		finished = true
		return

	var next = path.path[path.current_index]

	if pos.grid_pos == next:
		path.current_index += 1
		return

	var dir = next - pos.grid_pos

	if dir.x != 0:
		pos.grid_pos.x += sign(dir.x)
	elif dir.y != 0:
		pos.grid_pos.y += sign(dir.y)
