class_name AttackAction
extends Action

func execute(entity: Entity, delta: float):
	var pos_comp : PositionComponent = entity.get_component(PositionComponent)
	var target_comp : TargetComponent = entity.get_component(TargetComponent)
	var attack_comp : AttackComponent = entity.get_component(AttackComponent)
	#if target!=null:
		#get_component(TargetComponent).target_pos = target.get_component(PositionComponent).grid_pos
	if GridUtils.is_adjacent(pos_comp.grid_pos, target_comp.attack_target.get_component(PositionComponent).grid_pos):
		if attack_comp.attack_cooldown<attack_comp.attack_speed:
			attack_comp.attack_cooldown+=delta
			return
		attack_comp.attack_cooldown=0
		if !is_instance_valid(target_comp.attack_target):
			return
		#target.get_component(HealthComponent).take_damage(attack_damage)
		print("atacando!")
		return
	else:
		finished = true
