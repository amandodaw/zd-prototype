class_name ActionSystem

func update(delta : float, entities: Array[Entity]):
	for e in entities:
		var plan_comp : PlanComponent = e.get_component(PlanComponent)
		if not plan_comp:
			continue

		# si no hay acción activa → coger siguiente de la cola
		if plan_comp.current_action == null:
			if plan_comp.plan.is_empty():
				continue

			plan_comp.current_action = plan_comp.plan.pop_front()

		var action = plan_comp.current_action

		action.execute(e, delta)

		if action.is_finished():
			plan_comp.current_action = null
