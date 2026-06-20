extends Node

const MAX_CHANNELS: int = 3

enum SFX {
	PLACE,
	PURCHASE,
	CANNOT_PURCHASE,
	SELECT,
	DESELECT,
	GRID_MOVE,
}

const SFX_PATHS: Dictionary = {
	SFX.PLACE:            "res://Assets/Sounds/place.mp3",
	SFX.PURCHASE:         "res://Assets/Sounds/purchase.mp3",
	SFX.CANNOT_PURCHASE:  "res://Assets/Sounds/cannot_purchase.mp3",
	SFX.SELECT:           "res://Assets/Sounds/select.mp3",
	SFX.DESELECT:         "res://Assets/Sounds/deselect.mp3",
	SFX.GRID_MOVE:        "res://Assets/Sounds/grid_move.mp3",
}

const SFX_VOLUME_DB: Dictionary = {
	SFX.PLACE:            -6.0,
	SFX.PURCHASE:         0.0,
	SFX.CANNOT_PURCHASE:  0.0,
	SFX.SELECT:           -3.0,
	SFX.DESELECT:         -3.0,
	SFX.GRID_MOVE:        -12.0,
}

var _streams: Dictionary = {}
var _players: Array[AudioStreamPlayer2D] = []

### 

func _ready() -> void:
	_preload_streams()
	_create_pool()

func _preload_streams() -> void:
	for sfx in SFX_PATHS:
		_streams[sfx] = load(SFX_PATHS[sfx])

func _create_pool() -> void:
	for i in MAX_CHANNELS:
		var player := AudioStreamPlayer2D.new()
		add_child(player)
		_players.append(player)

## Play a sound. Optionally pass a world-space position for 2D audio falloff.
func play(sfx: SFX, world_position: Vector2 = Vector2.ZERO, random_pitch: bool = false) -> void:
	var player := _get_free_player()
	if player == null:
		return
	player.stream = _streams[sfx]
	player.volume_db = SFX_VOLUME_DB.get(sfx, 0.0)
	
	if random_pitch:
		randomize()
		player.pitch_scale = randf_range(0.9, 1.2)
	
	if world_position != Vector2.ZERO:
		player.position = world_position
	player.play()

func _get_free_player() -> AudioStreamPlayer2D:
	for player in _players:
		if not player.playing:
			return player
	return null
