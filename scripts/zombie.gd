extends Entity

var find_cont : float = 0.0
var find_threshold : float = 2.0

func _process(delta: float) -> void:
	follow_path(delta)
	if find_cont<find_threshold:
		find_cont += delta
		return
	find_cont = 0
	choose_target()

func find_human() ->bool:
	target_pos = find_nearest("human")
	if target_pos == INVALID:
		print("no human found")
		return false
	
	if check_target_in_range(3):
		print("human in range")
		return true
	
	print("no human in range")
	return false

func choose_target() -> void:
	if find_human():
		set_astar_path()
		return
	target_pos = find_nearest("wall")
	if target_pos == INVALID:
		print("no human or wall to attack")
		return
	set_astar_path()
	
