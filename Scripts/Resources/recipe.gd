extends Resource
class_name Recipe

@export var input: Array[RecipeIngredient]
@export var output: RecipeIngredient
@export var production_time: float = 2.0

func produce() -> RecipeIngredient:
	return output

func can_produce(current_recipe: Recipe, current_input: Array[RecipeIngredient]) -> bool:
	var valid = false
	for i in current_input:
		if current_recipe.input.has(current_input[i]):
			var current_input_item = current_input[i].item
			var current_input_amount = current_input[i].amount
			var required_amount = current_recipe.input[current_recipe.input.find(current_input_item)].amount
			if current_input_amount >= required_amount:
				valid = true
	return valid
