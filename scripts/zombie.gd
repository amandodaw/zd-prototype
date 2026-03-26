extends Entity

#func _process(delta: float) -> void:
	#attack(delta)
	#if find_cont<find_threshold:
		#find_cont += delta
		#return
	#find_cont = 0W
	#choose_target()
#
#func find_human() ->bool:
	#get_component(TargetComponent).target_pos = find_nearest_alive("human")
	#if get_component(TargetComponent).target_pos == GridUtils.INVALID:
		#print("no human found")
		#return false
	#
	#if check_target_in_range(10):
		#print("human in range", get_component(PositionComponent).grid_pos, get_component(TargetComponent).target_pos)
		#target = city_comp.living_entities[get_component(TargetComponent).target_pos]
		#return true
	#
	#print("no human in range")
	#return false
#
#func choose_target() -> void:
	#if find_human():
		#set_astar_path()
		#return
	#get_component(TargetComponent).target_pos = find_nearest_alive("wall")
	#print("pared encontrada :", get_component(TargetComponent).target_pos)
	#if get_component(TargetComponent).target_pos == GridUtils.INVALID:
		#print("no human or wall to attack")
		#return
	#if !city_comp.living_entities.has(get_component(TargetComponent).target_pos):
		#return
	#target = city_comp.living_entities[get_component(TargetComponent).target_pos]
	#set_astar_path()
	
