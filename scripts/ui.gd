extends Control

@onready var wood_label : Label = $TopBar/Resources/HBoxContainer/WoodLabel

@onready var gather_button : Button = $BottomPanel/Orders/VBoxContainer/GatherButton

var city_comp : CityComponent

var cont: float = 0.0

func _process(delta: float) -> void:
	cont += delta
	if cont>=1:
		cont=0
		update_resources(city_comp.wood_amount)

func update_resources(amount):
	wood_label.text = "Wood: " + str(amount)


func _on_gather_button_pressed() -> void:
	city_comp.tasks["gather_resources"] = !city_comp.tasks["gather_resources"]
	gather_button.text = "Gather resources: " + str(city_comp.tasks["gather_resources"])
