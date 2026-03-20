class_name CityComponent

var wood_amount : int = 0
var axe_amount : int = 0
var buildings : Array

enum Tasks {
	GATHER_RESOURCES,
	BUILD,
	MAKE,
	IDLE
}

var tasks : Dictionary[int, bool] = {
	Tasks.GATHER_RESOURCES : false,
	Tasks.BUILD : false,
	Tasks.MAKE : false,
	Tasks.IDLE : false
}

var build_orders : Dictionary[Vector2i, BuildOrderComponent] = {}
var reserved_tiles : Dictionary[Vector2i, bool] = {}
var make_orders : Array[String] = []
var entities : Dictionary = {}
var living_entities : Dictionary[Vector2i, Entity] = {}

var astar : AStarGrid2D
