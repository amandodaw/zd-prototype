extends Sprite2D
class_name Entity

#NUEVA MIERDA
var componentes := {}

func add_component(component) -> void:
	componentes[component.get_script()] = component

func get_component(component_script):
	return componentes.get(component_script, null)

func remove_component(component) ->void:
	componentes.erase(component)

func has_component(component) ->bool:
	return componentes.has(component)

# FIN MIERDA NUEVA
#
#var speed := 0.1
#var speed_cont := 0.0

var elements_map : TileMapLayer
#var city_comp : CityComponent
#
#var entity_type : String
#
#var path : Array[Vector2i]
#var path_index = 0
#
#var attack_speed : float = 3.0
#var attack_damage : int = 1
#var attack_cooldown : float = 0.0
#
#var target : Entity

# ------------------------------------------------
# PATH
# ------------------------------------------------

#func set_astar_path() ->void:
	#var choosed_pos = get_component(TargetComponent).target_pos
	#if !city_comp.astar.is_in_bounds(choosed_pos.x, choosed_pos.y):
		#return
	#if city_comp.astar.is_point_solid(get_component(TargetComponent).target_pos):
		#get_component(TargetComponent).adyacent_target_pos =  choose_adjacent(get_component(TargetComponent).target_pos)
		#choosed_pos = get_component(TargetComponent).adyacent_target_pos
	#if choosed_pos == GridUtils.INVALID:
		#print("no path to take")
		#return
	#
	#path = city_comp.astar.get_id_path(get_component(PositionComponent).grid_pos, choosed_pos)
#
#func follow_path(delta : float) ->void:
	#if path.is_empty():
		#return
	#if speed_cont>=speed:
		#speed_cont=0
		#if get_component(PositionComponent).grid_pos==path[0]: 
			#path.pop_at(0)
		#move_to_path_point()
		#return 
	#speed_cont += delta
	#
	#
#
## ------------------------------------------------
## MOVE
## ------------------------------------------------
#
#func move_to_path_point():
	#if path.is_empty():
		#return
	#city_comp.living_entities.erase(get_component(PositionComponent).grid_pos)
	#
	#get_component(PositionComponent).grid_pos = path[0]
	#position = get_component(PositionComponent).grid_pos*GridUtils.TILE_SIZE
	#
	#city_comp.living_entities.set(get_component(PositionComponent).grid_pos, self)
	#
#
## ------------------------------------------------
## COMBAT
## ------------------------------------------------
#
#func attack(delta : float) -> void:
	#if target!=null:
		#get_component(TargetComponent).target_pos = target.get_component(PositionComponent).grid_pos
	#if GridUtils.is_adjacent(get_component(PositionComponent).grid_pos, get_component(TargetComponent).target_pos):
		#if attack_cooldown<attack_speed:
			#attack_cooldown+=delta
			#return
		#attack_cooldown=0
		#if !is_instance_valid(target):
			#return
		#target.get_component(HealthComponent).take_damage(attack_damage)
		#print(target, " ahora tiene ", str(target.get_component(HealthComponent).health))
		#return
	#set_astar_path()
	#follow_path(delta)
#
## ------------------------------------------------
## UTILS
## ------------------------------------------------
#
#func find_nearest(type:String) -> Vector2i:
#
	#var best := GridUtils.INVALID
	#var best_dist := 999999
#
	#for tile in city_comp.entities:
#
		#if city_comp.entities[tile] != type:
			#continue
			#
		#if tile in city_comp.reserved_tiles:
			#continue
#
		#var dist = abs(tile.x - get_component(PositionComponent).grid_pos.x) + abs(tile.y - get_component(PositionComponent).grid_pos.y)
#
		#if dist < best_dist:
			#best_dist = dist
			#best = tile
#
	#return best
#
#func find_nearest_alive(type:String) -> Vector2i:
#
	#var best := GridUtils.INVALID
	#var best_dist := 999999
	#
	#for tile in city_comp.living_entities.keys():
		#if !is_instance_valid(city_comp.living_entities[tile]) or city_comp.living_entities[tile].entity_type != type:
			#continue
		#var dist = abs(tile.x - get_component(PositionComponent).grid_pos.x) + abs(tile.y - get_component(PositionComponent).grid_pos.y)
#
		#if dist < best_dist:
			#best_dist = dist
			#best = tile
#
	#return best
#
#func choose_adjacent(target: Vector2i) -> Vector2i:
	#var best_pos = GridUtils.INVALID
	#var best_dist = INF
	#
	#var directions = [
		#Vector2i(0, -1), # arriba
		#Vector2i(0, 1),  # abajo
		#Vector2i(-1, 0), # izquierda
		#Vector2i(1, 0)   # derecha
	#]
	#
	#for dir in directions:
		#var candidate = target + dir
		#
		## comprobar si es válida
		#if not is_cell_walkable(candidate):
			#continue
		#
		## distancia desde el humano
		#var dist = abs(candidate.x - get_component(PositionComponent).grid_pos.x) + abs(candidate.y - get_component(PositionComponent).grid_pos.y)
		#
		#if dist < best_dist:
			#best_dist = dist
			#best_pos = candidate
	#
	#return best_pos
#
#func is_cell_walkable(cell: Vector2i) -> bool:
	#if city_comp.astar.is_point_solid(cell):
		#return false
	#if cell in city_comp.reserved_tiles:
		#return false
	#return true
#
#func check_target_in_range(range : int) -> bool:
	#if abs(get_component(TargetComponent).target_pos.x - get_component(PositionComponent).grid_pos.x) + abs(get_component(TargetComponent).target_pos.y - get_component(PositionComponent).grid_pos.y) <= range:
		#return true
	#return false
#
#func reserve_target() -> void:
	#city_comp.reserved_tiles.set(get_component(TargetComponent).target_pos, true)
#
#func release_target() -> void:
	#if get_component(TargetComponent).target_pos in city_comp.reserved_tiles:
		#city_comp.reserved_tiles.erase(get_component(TargetComponent).target_pos)
