extends Camera2D



# Configuración
var scroll_speed := 500.0
var border_margin := 20.0

func _ready() -> void:
	position = get_viewport_rect().size/2

func _process(delta):
	move_camera(delta)

func move_camera(delta):
	var mouse_pos = get_viewport().get_mouse_position()
	var screen_size = get_viewport_rect().size
	var direction = Vector2.ZERO

	# Horizontal
	if mouse_pos.x < border_margin:
		direction.x -= 1
	elif mouse_pos.x > screen_size.x - border_margin:
		direction.x += 1

	# Vertical
	if mouse_pos.y < border_margin:
		direction.y -= 1
	elif mouse_pos.y > screen_size.y - border_margin:
		direction.y += 1

	if direction != Vector2.ZERO:
		position += direction.normalized() * scroll_speed * delta
