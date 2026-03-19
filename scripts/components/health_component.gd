class_name HealthComponent

var health : int = 3
var is_dead : bool = false

func take_damage(damage_amount : int) -> void:
	#modulate = Color.RED
	health -= damage_amount
	if health==0:
		die()
	#if is_inside_tree():
		#return
	#await get_tree().create_timer(0.33).timeout
	#modulate = Color.WHITE

func die() -> void:
	#release_target()
	is_dead = true
