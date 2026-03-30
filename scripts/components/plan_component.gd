class_name PlanComponent

var plan : Array[Action] = []
var current_action : Action = null
var needs_replan : bool = false
var repath_timer := 0.0
var repath_interval := 0.3
