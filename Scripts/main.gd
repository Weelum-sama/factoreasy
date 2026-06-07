extends Node2D

func _ready() -> void:
	GameState.game_paused.connect(_on_pause)

func _on_pause(paused: bool) -> void:
	var pause_menu: PauseMenu = $PauseMenu
	if not pause_menu:
		return
	
	if paused:
		pause_menu.show_menu()
	else:
		pause_menu.hide_menu()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Cancel"):
		GameState.game_paused.emit(false)
