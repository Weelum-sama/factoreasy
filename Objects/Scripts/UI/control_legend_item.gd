extends PanelContainer
class_name ControlLegendItem

@onready var _action_label: Label = %ActionLabel
@onready var _input_label: Label = %InputLabel

var action := "action"
var input := "input"

func _ready() -> void:
	set_action_label(action)
	set_input_label(input)

func set_action_label(action: String) -> void:
	_action_label.text = action

func set_input_label(input: String) -> void:
	_input_label.text = input
