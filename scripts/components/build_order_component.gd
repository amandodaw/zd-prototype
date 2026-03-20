class_name BuildOrderComponent

var cost: int
var progress: float = 0.0
var needed: float
var origin: Vector2i
var form: Array[Vector2i]

func _init(_cost, _needed, _origin := Vector2i.ZERO, _form := []):
	cost = _cost
	needed = _needed
	origin = _origin
	form = _form
