extends Node

const UPGRADE_BUTTON = preload("res://Objects/Scenes/UI/upgrade_button.tscn")

const UPGRADE_PATHS := [
	"res://Scripts/Resources/Upgrades/factory_upgrade_data.tres",
	"res://Scripts/Resources/Upgrades/belt_upgrade_data.tres"
]

var _buttons: Dictionary = {}

signal upgrade_purchased(upgrade_id: String)

func _ready() -> void:
	GameState.coins_changed.connect(_on_coins_changed)
	_refresh()

func _refresh() -> void:
	for child in get_children():
		child.queue_free()
	_buttons.clear()
	for path in UPGRADE_PATHS:
		if ResourceLoader.exists(path):
			_add_entry(load(path))

func _add_entry(data: UpgradeData) -> void:
	var button: UpgradeButton = UPGRADE_BUTTON.instantiate()
	add_child(button)
	data.decide_upgrade_cost()
	button.setup(data)
	button.update_affordability(GameState.get_total_coins() >= button.data.get_cost())
	button.upgrade_pressed.connect(_on_upgrade_pressed)
	_buttons[data.upgrade_id] = button

func _on_upgrade_pressed(data: UpgradeData) -> void:
	var cost := data.get_cost()
	if GameState.get_total_coins() < cost:
		return
	GameState.add_coins(-cost)
	GameState.upgrade_level(data.upgrade_id)
	
	var button: UpgradeButton = _buttons.get(data.upgrade_id)
	button.data.decide_upgrade_cost()
	if button:
		button._refresh_labels()
		button.update_affordability(GameState.get_total_coins() >= button.data.get_cost())
	upgrade_purchased.emit(data.upgrade_id)

func _on_coins_changed(new_amount: float) -> void:
	for upgrade_id in _buttons:
		var button: UpgradeButton = _buttons[upgrade_id]
		var cost := button.data.get_cost()
		button.update_affordability(new_amount >= cost)
