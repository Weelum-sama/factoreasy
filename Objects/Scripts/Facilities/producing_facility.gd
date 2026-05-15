extends Node2D
class_name ProducingFacility

@export var facility_data: FacilityData

var amount_in_input: int = 0
var amount_in_output: int = 0

var _timer: float = 0.0
var _input_buffer: Item
var _output_buffer: Item

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
	# TODO: Make this scalable for when multiple inputs are required
	var current_ingredient = RecipeIngredient.new()
	current_ingredient.item = _input_buffer
	current_ingredient.amount = amount_in_input
	if not recipe.can_produce(recipe, Array(current_ingredient)):
		return
	
	var output_ingredient = recipe.produce()
	var item = output_ingredient.item
	var amount = output_ingredient.amount
	# TODO: Add amount of items to depot

func receive_item(item: Item, amount: int) -> bool:
	_input_buffer = item
	amount_in_input += amount
	return true

func take_item(item: Item) -> bool:
	if amount_in_output <= 0:
		return false
	amount_in_output -= 1
	return true
