extends ContextMenuBase
class_name RecipeContextMenu

@onready var _title_label: Label         = %TitleLabel
@onready var _time_label: Label          = %TimeLabel
@onready var _input_list: VBoxContainer  = %InputList
@onready var _output_icon: TextureRect   = %OutputIcon
@onready var _output_label: Label        = %OutputLabel

func open(recipe: Recipe, screen_pos: Vector2) -> void:
	var output := recipe.output
	_title_label.text = (output.item.name + " recipe") if output and output.item else "recipe"
	_time_label.text = "%.1f s / unit" % recipe.production_time
	
	for child in _input_list.get_children():
		child.queue_free()
	for ingredient in recipe.input:
		_input_list.add_child(_ingredient_row(ingredient))
	
	if output and output.item:
		_output_icon.texture = output.item.texture
		_output_label.text = "%s x%d" % [output.item.name, output.amount]
		_setup_output_click(output.item)
	
	visible = true
	_position_clamped(screen_pos)

func _setup_output_click(item: Item) -> void:
	var output_row := _output_icon.get_parent()
	
	if output_row.gui_input.is_connected(_on_output_clicked):
		output_row.gui_input.disconnect(_on_output_clicked)
	output_row.gui_input.connect(_on_output_clicked.bind(item))
	
	output_row.mouse_entered.connect(func() -> void: output_row.modulate = Color(1.15, 1.15, 1.15))
	output_row.mouse_exited.connect(func() -> void: output_row.modulate = Color.WHITE)

func _on_output_clicked(event: InputEvent, item: Item) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var layer := get_parent() as ContextMenuLayer
		if layer:
			layer.open_item(item, get_viewport().get_mouse_position())

func _ingredient_row(ingredient: RecipeIngredient) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	row.mouse_filter = Control.MOUSE_FILTER_STOP

	var icon := TextureRect.new()
	icon.texture = ingredient.item.texture if ingredient.item else null
	icon.custom_minimum_size = Vector2(16, 16)
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	row.add_child(icon)
	
	var label := Label.new()
	label.text = "%s ×%d" % [ingredient.item.name if ingredient.item else "?", ingredient.amount]
	row.add_child(label)

	row.mouse_entered.connect(func() -> void: row.modulate = Color(1.15, 1.15, 1.15))
	row.mouse_exited.connect(func() -> void:  row.modulate = Color.WHITE)
	row.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if ingredient.item:
				var layer := get_parent() as ContextMenuLayer
				if layer:
					layer.open_item(ingredient.item, get_viewport().get_mouse_position())
	)
	return row
