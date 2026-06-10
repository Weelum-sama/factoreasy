extends BaseFacility
class_name ProcessingFacility

var _production_timer: float = 0.0
var _is_producing: bool = false

func tick() -> void:
	var data := get_data() as ProcessingFacilityData
	if data == null or data.recipes.is_empty():
		return
	
	if _is_producing:
		var recipe := get_current_recipe()
		if recipe == null:
			_is_producing = false
			return
		_production_timer += TickManager.TICK_RATE
		_set_state(Util.FACILITYSTATE.PRODUCING)
		if _production_timer >= recipe.production_time:
			_production_timer = 0.0
			_is_producing = false
			_complete_production(recipe)
	else:
		if input_buffer.is_empty():
			_set_state(Util.FACILITYSTATE.IDLE)
			return
		set_current_recipe()
		var recipe := get_current_recipe()
		if output_buffer.get(recipe.output.item, 0) >= MAX_BUFFER:
			_set_state(Util.FACILITYSTATE.CLOGGED)
			return
		if recipe.can_produce(input_buffer):
			_consume_inputs(recipe)
			_is_producing = true
			_production_timer = 0.0
		else:
			_set_state(Util.FACILITYSTATE.IDLE)

func _consume_inputs(recipe: Recipe) -> void:
	for ingredient in recipe.input:
		input_buffer[ingredient.item] -= ingredient.amount

func _complete_production(recipe: Recipe) -> void:
	var out := recipe.output
	output_buffer[out.item] = output_buffer.get(out.item, 0) + out.amount
