class_name CityComponent

var wood_amount : int = 0
var axe_amount : int = 0
var buildings : Array

var tasks : Dictionary[String, int] = {
	"gather_resources" : false,
	"make_axe": false
}

var build_orders : Dictionary[Vector2i, String] = {}
