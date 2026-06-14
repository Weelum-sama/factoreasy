extends Placeable
class_name Belt

@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D

var belt_item: BeltItem = null

var belt_state: Util.BELTSTATE = Util.BELTSTATE.WORKING

var _split_index: int = 0

func _ready() -> void:
	var ips := get_items_per_second()
	animated_sprite_2d.speed_scale = ips
	animated_sprite_2d.play("default")
	_sync_animation()

func register() -> void:
	var cell := GridManager.world_to_cell(global_position)
	BeltManager.register_belt(cell, self)

func get_items_per_second() -> float:
	return BeltManager.belt_speed / 60.0

func update_animation_speed() -> void:
	animated_sprite_2d.speed_scale = get_items_per_second()
	_sync_animation()

func get_output_cell() -> Vector2i:
	return GridManager.world_to_cell(global_position) + Util.get_facing_offset(rotation)

func get_input_cell() -> Vector2i:
	return GridManager.world_to_cell(global_position) - Util.get_facing_offset(rotation)

func set_belt_state(new_state: Util.BELTSTATE) -> void:
	if belt_state == new_state:
		return
	belt_state = new_state
	match new_state:
		Util.BELTSTATE.WORKING:
			animated_sprite_2d.play("default")
			_sync_animation()
		Util.BELTSTATE.CLOGGED:
			animated_sprite_2d.pause()

func move_to(new_cell: Vector2i) -> void:
	var old_cell := GridManager.world_to_cell(global_position)
	var delta := new_cell - old_cell
	
	if belt_item != null:
		belt_item.previous_cell += delta
		belt_item.current_cell += delta
	
	BeltManager.update_delivery_cells(old_cell, delta)
	
	BeltManager.unregister_belt(old_cell)
	super.move_to(new_cell)
	BeltManager.register_belt(new_cell, self)

func _sync_animation() -> void:
	var frame_count := animated_sprite_2d.sprite_frames.get_frame_count("default")
	var fps := animated_sprite_2d.sprite_frames.get_animation_speed("default") * animated_sprite_2d.speed_scale
	if fps <= 0:
		return
	
	var time_seconds := Time.get_ticks_msec() / 1000.0
	var cycle_position := fmod(time_seconds * fps, frame_count)
	animated_sprite_2d.frame = int(cycle_position)
	animated_sprite_2d.frame_progress = fmod(cycle_position, 1.0)

func cleanup() -> void:
	BeltManager.unregister_belt(GridManager.world_to_cell(global_position))
	GridManager.remove(GridManager.world_to_cell(global_position))
	queue_free()
