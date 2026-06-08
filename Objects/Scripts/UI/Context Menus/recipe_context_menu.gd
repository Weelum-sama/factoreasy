extends Control

@onready var output_icon: TextureRect = %OutputIcon
@onready var name_label: Label = %NameLabel
@onready var production_time_label: Label = %ProductionTimeLabel
@onready var input_container: HBoxContainer = %InputHBoxContainer

func setup(recipe: Recipe) -> void:
	if not is_instance_valid(recipe):
		return
	output_icon.texture = recipe.output.item.texture
	name_label.text = recipe.output.item.name
	production_time_label.text = str(recipe.production_time)
	
	for input in recipe.input:
		pass # create menu items for input container
