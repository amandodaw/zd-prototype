extends Control

@onready var wood_label : Label = $TopBar/Resources/HBoxContainer/WoodLabel
@onready var axe_label : Label = $TopBar/Resources/HBoxContainer/AxeLabel

@onready var gather_button : Button = $BottomPanel/Orders/VBoxContainer/GatherButton
@onready var build_button : Button = $BottomPanel/Orders/VBoxContainer/BuildButton
@onready var make_button : Button = $BottomPanel/Orders/VBoxContainer/MakeButton
@onready var make_axe_button : Button = $BottomPanel/Orders/VBoxContainer/MakeAxe

var city_comp : CityComponent

var elements_map : TileMapLayer

var cont: float = 0.0

var build_workplace : bool = false
var build_wall : bool = false

var build_order : Vector2i = Vector2i(11, 7)



func _process(delta: float) -> void:
	cont += delta
	if cont>=1:
		cont=0
		update_resources()
	if Input.is_action_just_pressed("mouse_left"):

		if build_workplace:
			var mouse_world = elements_map.get_global_mouse_position()
			var base_cell = elements_map.local_to_map(elements_map.to_local(mouse_world))
			elements_map.set_cell(base_cell, 0, build_order)
			city_comp.build_orders.set(base_cell, "workplace_order")
			build_workplace = false
		if build_wall:
			var mouse_world = elements_map.get_global_mouse_position()
			var base_cell = elements_map.local_to_map(elements_map.to_local(mouse_world))
			elements_map.set_cell(base_cell, 0, build_order)
			city_comp.build_orders.set(base_cell, "wall_order")
			build_wall = false

func update_resources():
	wood_label.text = "Wood: " + str(city_comp.wood_amount)
	axe_label.text = "Axes: " + str(city_comp.axe_amount)


func _on_gather_button_pressed() -> void:
	city_comp.tasks[city_comp.Tasks.GATHER_RESOURCES] = !city_comp.tasks[city_comp.Tasks.GATHER_RESOURCES]
	gather_button.text = "Gather resources: " + str(city_comp.tasks[city_comp.Tasks.GATHER_RESOURCES])


func _on_build_workshop_pressed() -> void:
	build_workplace = true
	print("build workplace activated")


func _on_make_sword_pressed() -> void:
	city_comp.make_orders.append("make_axe")
	make_axe_button.text = "Make axe: " + str(city_comp.make_orders.size())


func _on_build_wall_pressed() -> void:
	build_wall = true
	print("build wall activated")


func _on_build_button_pressed() -> void:
	city_comp.tasks[city_comp.Tasks.BUILD] = !city_comp.tasks[city_comp.Tasks.BUILD]
	build_button.text = "Build mode: " + str(city_comp.tasks[city_comp.Tasks.BUILD])


func _on_make_button_pressed() -> void:
	city_comp.tasks[city_comp.Tasks.MAKE] = !city_comp.tasks[city_comp.Tasks.MAKE]
	make_button.text = "Make mode: " + str(city_comp.tasks[city_comp.Tasks.MAKE])
