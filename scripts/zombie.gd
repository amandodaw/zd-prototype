extends Entity

var find_cont : float = 0.0
var find_threshold : float = 2.0

enum States {
	ATTACK
}

var state : States = States.ATTACK

func _process(delta: float) -> void:
	attack(delta)
	if find_cont<find_threshold:
		find_cont += delta
		return
	find_cont = 0
	choose_target()

func find_human() ->bool:
	target_pos = find_nearest_alive("human")
	if target_pos == INVALID:
		print("no human found")
		return false
	
	if check_target_in_range(10):
		print("human in range", grid_pos, target_pos)
		target = city_comp.living_entities[target_pos]
		return true
	
	print("no human in range")
	return false

func choose_target() -> void:
	if find_human():
		set_astar_path()
		return
	target_pos = find_nearest_alive("wall")
	print("pared encontrada :", target_pos)
	if target_pos == INVALID:
		print("no human or wall to attack")
		return
	if !city_comp.living_entities.has(target_pos):
		return
	target = city_comp.living_entities[target_pos]
	set_astar_path()
	
