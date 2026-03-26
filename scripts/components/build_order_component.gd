class_name BuildOrderComponent

var cost: int
var progress: float = 0.0
var needed: float
var origin: Vector2i
var form: Array[Vector2i]

enum State {
	FREE,
	RESERVED,
	IN_PROGRESS,
	DONE
}

var state := State.FREE
var worker : Entity = null

func _init(_cost, _needed, _origin := Vector2i.ZERO, _form := []):
	cost = _cost
	needed = _needed
	origin = _origin
	form = _form
