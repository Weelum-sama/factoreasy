extends CanvasLayer

@onready var anchor_center: Control = $AnchorCenter
@onready var missing_label: Label = %MissingLabel

var tween: Tween

func _ready() -> void:
	Util.cannot_copy_selection.connect(_on_cannot_copy_selection)
	Util.copied_selection.connect(_speed_tween_up)
	Util.cancelled_copy_selection.connect(_speed_tween_up)

func _on_cannot_copy_selection(missing_nodes: Dictionary):
	_update_missing_label(missing_nodes)
	_play_tween_animation()

func _speed_tween_up() -> void:
	if tween:
		tween.set_speed_scale(15.0)


func _play_tween_animation() -> void:
	if tween:
		tween.kill()
	anchor_center.modulate = Color.WHITE
	tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(anchor_center, "scale", Vector2(1.2, 1.2), .1)
	tween.tween_property(anchor_center, "scale", Vector2(1.0, 1.0), .15)
	tween.tween_interval(1.5)
	tween.tween_property(anchor_center, "modulate", Color(1, 1, 1, 0), 4.0)

func _update_missing_label(missing_nodes: Dictionary):
	missing_label.text = "missing:"
	for missing_node in missing_nodes.keys():
		var missing: int = missing_nodes[missing_node] - GameState.node_inventory[missing_node]
		var display_name: String = GameState.facility_registry[missing_node].display_name
		missing_label.text += "\n%s %d" % [display_name, missing]
