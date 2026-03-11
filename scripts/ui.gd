extends Control

@onready var wood_label : Label = $TopBar/Resources/HBoxContainer/WoodLabel

@onready var gather_button : Button = $BottomPanel/Orders/VBoxContainer/GatherButton

var city_comp : CityComponent

var elements_map : TileMapLayer

var cont: float = 0.0

var build_mode : bool = false

var build_order : Vector2i = Vector2i(11, 7)



func _process(delta: float) -> void:
	cont += delta
	if cont>=1:
		cont=0
		update_resources(city_comp.wood_amount)
	if Input.is_action_just_pressed("mouse_left"):

		if build_mode:
			var mouse_world = elements_map.get_global_mouse_position()
			var base_cell = elements_map.local_to_map(elements_map.to_local(mouse_world))
			elements_map.set_cell(base_cell, 0, build_order)
			city_comp.build_orders.set(base_cell, "workplace")
			build_mode = false

func update_resources(amount):
	wood_label.text = "Wood: " + str(amount)


func _on_gather_button_pressed() -> void:
	city_comp.tasks["gather_resources"] = !city_comp.tasks["gather_resources"]
	gather_button.text = "Gather resources: " + str(city_comp.tasks["gather_resources"])


func _on_build_workshop_pressed() -> void:
	build_mode = true
	print("build mode activated")
	
