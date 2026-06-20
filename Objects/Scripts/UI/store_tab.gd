extends VBoxContainer

const SHOP_BUTTON = preload("res://Objects/Scenes/UI/shop_button.tscn")

var _buttons: Dictionary = {}

func _ready() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	GameState.coins_changed.connect(_on_coins_changed)
	GameState.node_unlocked.connect(_on_node_unlocked)
	GameState.node_purchased.connect(_on_purchase)
	_refresh()

func _refresh() -> void:
	for child in get_children():
		child.queue_free()
	_buttons.clear()
	for node_id in GameState.NODE_ORDER:
		if not GameState.unlocked_nodes[node_id]:
			continue
		var path := "res://Scripts/Resources/Node Data/%s_data.tres" % node_id
		if ResourceLoader.exists(path):
			_add_entry(load(path))

func _add_entry(data: OreNodeData) -> void:
	var button: ShopButton = SHOP_BUTTON.instantiate()
	add_child(button)
	button.setup(data, data.cost, GameState.total_nodes_owned[data.id])
	button.pressed.connect(func(_d):
		if GameState.get_total_coins() >= data.cost:
			GameState.add_coins(-data.cost)
			GameState.purchase_node(data.id)
			Util.purchased.emit()
		else:
			Util.cannot_purchase.emit(data.cost - GameState.get_total_coins())
			AudioManager.play(AudioManager.SFX.CANNOT_PURCHASE)
	)
	_buttons[data.id] = button
	button.data.update_purchase_cost()
	button.update_label_cost(button.data.cost)
	button.update_affordability(GameState.get_total_coins() >= button.data.cost)

func _check_node_unlocks(new_coins: float) -> void:
	for node_id in GameState.NODE_ORDER:
		if GameState.unlocked_nodes[node_id]:
			continue
		var data: OreNodeData = GameState.facility_registry.get(node_id)
		if data and new_coins >= data.unlock_threshold:
			GameState.unlock_node(node_id)

func _on_coins_changed(new_amount: float) -> void:
	_check_node_unlocks(new_amount)
	for node_id in _buttons:
		var button: ShopButton = _buttons[node_id]
		button.update_affordability(new_amount >= button.data.cost)

func _on_node_unlocked(_id: String) -> void:
	_refresh()

func _on_purchase(node_id: String, _amount: int) -> void:
	_buttons[node_id].data.update_purchase_cost()
	_buttons[node_id].update_label_owned(GameState.total_nodes_owned[node_id])
	_buttons[node_id].update_label_cost(_buttons[node_id].data.cost)
	AudioManager.play(AudioManager.SFX.PURCHASE)

### TESTING PURPOSES
var amount = 80
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Test"):
		GameState.add_coins(amount)
		GameState.reset_save_data()
		amount *= 10
