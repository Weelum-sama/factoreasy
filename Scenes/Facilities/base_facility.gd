class_name BaseFacility
extends Node2D
var test : float

var recipes : Dictionary
var output

enum Processables {IronOre, IronIngot}
@export var input : Util.RESOURCE_TYPES:
	get: return input
	set(value):
		input = value
		validateInput(input)
@export var text : RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass
	
func validateInput(input: Util.RESOURCE_TYPES) -> bool:
	match input:
		Util.RESOURCE_TYPES.IRON_ORE:
			text.text = ("This is Iron Ore")
			return true
		Util.RESOURCE_TYPES.IRON_INGOT:
			text.text = ("This is an Iron Ingot")
		_:
			text.text = "This can't be processed"
	return false
	pass
