class_name ResourceComponent

enum States {
	FREE,
	RESERVED,
	PICKED
}

var state : States = States.FREE

#var state : Dictionary[int, bool] = {
	#States.FREE : false,
	#States.RESERVED : false,
	#States.PICKED : false
#}
