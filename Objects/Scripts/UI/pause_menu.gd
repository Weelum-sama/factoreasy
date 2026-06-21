extends CanvasLayer
class_name PauseMenu

@onready var save_button: Button = %SaveButton
@onready var resume_button: Button = %ResumeButton
@onready var reset_progress_button: Button = %ResetProgressButton
@onready var audio_button: Button = %AudioButton

func _ready() -> void:
	hide_menu()
	save_button.pressed.connect(_on_save_button_pressed)
	resume_button.pressed.connect(_on_resume_button_pressed)
	reset_progress_button.pressed.connect(_on_reset_progress_button_pressed)
	audio_button.pressed.connect(_on_audio_button_pressed)

func show_menu() -> void:
	visible = true
	get_tree().paused = true

func hide_menu() -> void:
	visible = false
	get_tree().paused = false

func _on_save_button_pressed() -> void:
	GameState.save_game()
	
	save_button.text = "saved!"
	save_button.modulate = Color(0.01, 0.675, 0.0)
	await get_tree().create_timer(1.0).timeout
	save_button.modulate = Color.WHITE
	save_button.text = "save game"

func _on_resume_button_pressed() -> void:
	hide_menu()

func _on_reset_progress_button_pressed() -> void:
	GameState.reset_save_data()
	get_tree().quit()

func _on_audio_button_pressed() -> void:
	AudioManager.audio_toggle = !AudioManager.audio_toggle
	audio_button.text = "audio: on" if AudioManager.audio_toggle else "audio: off"
