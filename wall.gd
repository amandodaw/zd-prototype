extends Entity
class_name Wall

func die() -> void:
	print("soy pared y estoy muriendo")
	city_comp.astar.set_point_solid(grid_pos, false)
	city_comp.living_entities.erase(grid_pos)
	elements_map.erase_cell(grid_pos)
	#super()
