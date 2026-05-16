extends Node2D
class_name ProducingFacility

@export var facility_data: FacilityData

var _timer: float = 0.0
var _input_buffer: Dictionary = {}
var _output_buffer: Dictionary = {}

func _ready() -> void:
	if facility_data == null:
		push_error("Facility placed with no FacilityData assigned: " + name)

func _process(delta: float) -> void:
	if facility_data == null:
		return
	var recipe: Recipe = facility_data.get_active_recipe()
	if recipe == null:
		return
	
	_timer += delta
	if _timer >= recipe.production_time:
		_timer = 0.0
		_try_produce(recipe)

func _try_produce(recipe: Recipe) -> void:
	if not recipe.can_produce(_input_buffer):
		return
	# Consume inputs
	for ingredient in recipe.input:
		_input_buffer[ingredient.item] -= ingredient.amount
	# Add output
	var output_item := recipe.output.item
	_output_buffer[output_item] = _output_buffer.get(output_item, 0) + recipe.output.amount

func receive_item(item: Item, amount: int) -> bool:
	_input_buffer[item] = _input_buffer.get(item, 0) + amount
	return true

func take_item(item: Item) -> bool:
	if _output_buffer.get(item, 0) <= 0:
		return false
	_output_buffer[item] -= 1
	return true
