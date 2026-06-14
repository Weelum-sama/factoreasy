extends Container

const CONTROL_LEGEND_ITEM = preload("res://Objects/Scenes/UI/control_legend_item.tscn")
@onready var v_box_container: VBoxContainer = %VBoxContainer

var _current_items: Array[Node]

const universal_inputs: Dictionary = {
	"move camera: ": "WASD/arrows",
	"zoom: ": "scroll in/out",
	"rotate camera: ": "ctrl+R",
	"confirm: ": "left mouse button",
	"cancel: ": "right mouse button / ESC",
}

const default_inputs: Dictionary = {
	"quick copy: ": "middle mouse button",
	"quick move": "hold left mouse button",
	"enter selectmode: ": "TAB",
	"place belts: ": "E",
}

const selection_inputs: Dictionary = {
	"leave selectmode: ": "TAB/right mouse button/ESC",
	"select/deselect: ": "left mouse button",
	"deselect": "hold ctrl + left mouse button",
	"select all: ": "Q",
	"move selection: ": "M",
	"stash selection: ": "F",
	"copy seleciton": "ctrl + C",
}

const placement_inputs: Dictionary = {
	"leave placementmode: ": "right mouse button/ESC",
	"confirm placement: ": "left mouse button",
	"rotate building: ": "R",
}

const group_move_inputs: Dictionary = {
	"cancel movement: ": "TAB/right mouse button/ESC",
	"rotate selection: ": "R",
	"confirm placement: ": "left mouse button",
}

const belt_inputs: Dictionary = {
	"stop placing belts: ": "right mouse button/ESC",
	"place multiple: ": "drag left mouse button",
	"rotate belt: ": "R",
	"confirm placement: ": "left mouse button",
}

func _ready() -> void:
	update_legend(Util.PLACEMENTMODE.NONE)
	Util.placement_mode_changed.connect(update_legend)

func update_legend(mode: Util.PLACEMENTMODE) -> void:
	_clear_items()
	match mode:
		Util.PLACEMENTMODE.NONE:
			_create_items(default_inputs)
		Util.PLACEMENTMODE.SELECTION:
			_create_items(selection_inputs)
		Util.PLACEMENTMODE.FACILITY:
			_create_items(placement_inputs)
		Util.PLACEMENTMODE.ORE_NODE:
			_create_items(placement_inputs)
		Util.PLACEMENTMODE.GROUP_MOVE:
			_create_items(group_move_inputs)
		Util.PLACEMENTMODE.BELT:
			_create_items(belt_inputs)

func _create_items(inputs: Dictionary) -> void:
	for key in inputs.keys():
		var item: ControlLegendItem = CONTROL_LEGEND_ITEM.instantiate()
		item.action = key
		item.input = inputs[key]
		v_box_container.add_child(item)
		_current_items.append(item)

func _clear_items() -> void:
	for item in _current_items:
		item.queue_free()
	_current_items.clear()
