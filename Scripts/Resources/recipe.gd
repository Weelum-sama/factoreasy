extends Resource
class_name Recipe

@export var input: Array[RecipeIngredient]
@export var output: RecipeIngredient
@export var production_time: float = 2.0

func produce() -> RecipeIngredient:
	return output

func can_produce(input_buffer: Dictionary) -> bool:
	for required in input:
		var available: int = input_buffer.get(required.item, 0)
		if available < required.amount:
			return false
	return true
