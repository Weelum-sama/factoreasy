extends CanvasLayer


func _ready() -> void:
	Util.cannot_copy_selection.connect(_on_cannot_copy_selection)

func _on_cannot_copy_selection(missing_nodes: Dictionary):
	print("cannot copy: ", missing_nodes)
	pass
