extends Control

@onready var wood_label : Label = $TopBar/Resources/HBoxContainer/WoodLabel
@onready var axe_label : Label = $TopBar/Resources/HBoxContainer/AxeLabel

@onready var gather_button : Button = $BottomPanel/Orders/VBoxContainer/GatherButton
@onready var build_button : Button = $BottomPanel/Orders/VBoxContainer/BuildButton
@onready var make_button : Button = $BottomPanel/Orders/VBoxContainer/MakeButton
@onready var make_axe_button : Button = $BottomPanel/Orders/VBoxContainer/MakeAxe
@onready var attack_button : Button = $BottomPanel/Orders/VBoxContainer/AttackButton

var city_comp : CityComponent

var elements_map : TileMapLayer

var cont: float = 0.0

var build_workplace : bool = false
var build_wall : bool = false

var build_orders : Array[BuildOrderComponent] = []
var placed_building := Vector2i(11, 7)



func _process(delta: float) -> void:
	cont += delta
	if cont>=1:
		cont=0
		update_resources()
	if Input.is_action_just_pressed("mouse_left"):
		var mouse_world = elements_map.get_global_mouse_position()
		var base_cell = elements_map.local_to_map(elements_map.to_local(mouse_world))
		var order_type : String
		if build_workplace:
			order_type = "workplace_order"
			place_build_order(base_cell, order_type)
		if build_wall:
			order_type = "wall_order"
			place_build_order(base_cell, order_type)

	
	if Input.is_action_just_pressed("mouse_right"):
		print("Build order desactivada")
		build_wall = false
		build_workplace = false

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

func place_build_order(base_cell : Vector2i, order_type : String) -> void:
	if elements_map.get_cell_source_id(base_cell)==-1:
		var data : BuildingData
		match order_type:
			"workplace_order":
				data = load("res://scripts/data/workplace_data.tres") as BuildingData
			"wall_order":
				data = load("res://scripts/data/wall_data.tres") as BuildingData
		var build_order : BuildOrderComponent = create_task_from_data(data)
		for offset in build_order.form:
			var target_cell = offset + base_cell
			elements_map.set_cell(target_cell, 0, placed_building)
			city_comp.astar.set_point_solid(target_cell, true)
		city_comp.build_orders.set(base_cell, build_order)
	else:
		print("ubicacion no valida")

func create_task_from_data(data: BuildingData) -> BuildOrderComponent:
	return BuildOrderComponent.new(
		data.cost,
		data.needed,
		data.origin,
		data.form
	)


func _on_attack_button_pressed() -> void:
	city_comp.tasks[city_comp.Tasks.ATTACK] = !city_comp.tasks[city_comp.Tasks.ATTACK]
	attack_button.text = "Attack mode: " + str(city_comp.tasks[city_comp.Tasks.ATTACK])
