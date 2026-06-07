extends CanvasLayer
class_name PauseMenu

@onready var save_button: Button = %SaveButton
@onready var resume_button: Button = %ResumeButton

func _ready() -> void:
	hide_menu()
	save_button.pressed.connect(_on_save_button_pressed)
	resume_button.pressed.connect(_on_resume_button_pressed)

func show_menu() -> void:
	visible = true
	get_tree().paused = true

func hide_menu() -> void:
	visible = false
	get_tree().paused = false

func _on_save_button_pressed() -> void:
	GameState.save_game()
	
	save_button.text = "saved!"
	await get_tree().create_timer(1.0).timeout
	save_button.text = "save game"

func _on_resume_button_pressed() -> void:
	hide_menu()
