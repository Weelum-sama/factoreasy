extends Container

const CONTROL_LEGEND_ITEM = preload("res://Objects/Scenes/UI/control_legend_item.tscn")
@onready var v_box_container: VBoxContainer = %VBoxContainer

func _ready() -> void:
	for action in InputMap.get_actions():
		if action.contains("ui"):
			continue
		
		var item: ControlLegendItem = CONTROL_LEGEND_ITEM.instantiate()
		var action_string: String
		var input_string: String
		
		var input = []
		
		input = InputMap.action_get_events(action)
		for i in input:
			input_string += action
		
		print("action: ", action, " input: ", input)
		#keycode = DisplayServer.keyboard_get_keycode_from_physical(input.get_physical_keycode()) as int
		
		#item.input = input_string
		#item.action = action_string
		#v_box_container.add_child(item)
