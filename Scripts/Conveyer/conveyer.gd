extends AnimatedSprite2D

var carried_object: Array[Area2D]

@export var carry_speed: float = 1.0
@export var direction: Util.DIRECTION

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#orientate_animation()
	#orientate_based_on_rotation()
	if carried_object.is_empty():
		return
	carry_object(carried_object[0], delta)
	pass

func carry_object(area: Area2D, delta: float) -> void:
	area.position += Vector2.UP * carry_speed * delta
	#area.translate(position + Vector2.UP)
	pass

func orientate_based_on_rotation() -> void:
	
	pass

func orientate_animation() -> void:
	match direction:
		Util.DIRECTION.UP:
			play("up")
		Util.DIRECTION.RIGHT:
			play("right")
		Util.DIRECTION.DOWN:
			play("down")
		Util.DIRECTION.LEFT:
			play("left")

func _on_area_2d_area_entered(area: Area2D) -> void:
	carried_object.assign([area])
