extends ContextMenuBase
class_name FacilityContextMenu

@onready var _title_label: Label    = %TitleLabel
@onready var _state_label: Label    = %StateLabel
@onready var _input_list: VBoxContainer  = %InputList
@onready var _output_list: VBoxContainer = %OutputList
@onready var _recipes_section: VBoxContainer = %RecipesSection
@onready var _recipe_list: VBoxContainer     = %RecipeList

func open(facility: BaseFacility, screen_pos: Vector2) -> void:
	_rebuild(facility)
	visible = true
	_position_clamped(screen_pos)

func _rebuild(facility: BaseFacility) -> void:
	var data := facility.get_data()
	_title_label.text = data.display_name if data else facility.facility_id
	
	match facility.facility_state:
		Util.FACILITYSTATE.IDLE:		_state_label.text = "state: idle"
		Util.FACILITYSTATE.PRODUCING:	_state_label.text = "state: producing"
		Util.FACILITYSTATE.CLOGGED:		_state_label.text = "state: clogged"
	
	_clear(_input_list)
	_clear(_output_list)
	_clear(_recipe_list)
	
	for item: Item in facility.input_buffer:
		var amount: int = facility.input_buffer[item]
		if amount > 0:
			_input_list.add_child(_item_row(item, amount))
	
	for item: Item in facility.output_buffer:
		var amount: int = facility.output_buffer[item]
		if amount > 0:
			_output_list.add_child(_item_row(item, amount))
	
	var processing_data := data as ProcessingFacilityData
	_recipes_section.visible = processing_data != null and not processing_data.recipes.is_empty()
	if processing_data:
		for recipe in processing_data.recipes:
			_recipe_list.add_child(_recipe_row(recipe))

func _item_row(item: Item, amount: int) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	var icon := TextureRect.new()
	icon.texture = item.texture
	icon.custom_minimum_size = Vector2(16, 16)
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	row.add_child(icon)
	var label := Label.new()
	label.text = "%s ×%d" % [item.name, amount]
	row.add_child(label)
	row.mouse_entered.connect(func() -> void: row.modulate = Color(1.15, 1.15, 1.15))
	row.mouse_exited.connect(func() -> void:  row.modulate = Color.WHITE)
	row.gui_input.connect(func(e: InputEvent) -> void:
		if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT and e.pressed:
			var layer := get_parent() as ContextMenuLayer
			if layer:
				layer.open_item(item, get_viewport().get_mouse_position())
		)
	return row

func _recipe_row(recipe: Recipe) -> PanelContainer:
	var panel := PanelContainer.new()
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 4)
	
	if recipe.output and recipe.output.item:
		var icon := TextureRect.new()
		icon.texture = recipe.output.item.texture
		icon.custom_minimum_size = Vector2(16, 16)
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		hbox.add_child(icon)
		var label := Label.new()
		label.text = recipe.output.item.name
		hbox.add_child(label)
	
	panel.add_child(hbox)
	panel.mouse_entered.connect(func() -> void: panel.modulate = Color(1.15, 1.15, 1.15))
	panel.mouse_exited.connect(func() -> void:  panel.modulate = Color.WHITE)
	panel.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var layer := get_parent() as ContextMenuLayer
			if layer:
				layer.open_recipe(recipe, get_viewport().get_mouse_position())
	)
	return panel

func _clear(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()
