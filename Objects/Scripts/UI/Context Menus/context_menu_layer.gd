extends CanvasLayer
class_name ContextMenuLayer

@onready var belt_menu: BeltContextMenu = $BeltContextMenu
@onready var facility_menu: FacilityContextMenu = $FacilityContextMenu
@onready var recipe_menu: RecipeContextMenu = $RecipeContextMenu
@onready var item_menu: ItemContextMenu     = $ItemContextMenu

var _stack_order: Array[ContextMenuBase] = []
var _stack: Array[ContextMenuBase] = []

func _ready() -> void:
	close_all()
	_stack_order = [facility_menu, belt_menu, recipe_menu, item_menu]
	_stack_order.reverse()
	GameState.game_paused.connect(func(paused: bool) -> void:
		if paused: close_all()
	)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Cancel"):
		close_top()

func open_for(node: Node, screen_pos: Vector2) -> void:
	close_all()
	if node is Belt:
		belt_menu.open(node as Belt, screen_pos)
		if not _stack.has(belt_menu):
			_stack.append(belt_menu)
	elif node is BaseFacility:
		facility_menu.open(node as BaseFacility, screen_pos)
		if not _stack.has(facility_menu):
			_stack.append(facility_menu)

func open_recipe(recipe: Recipe, screen_pos: Vector2) -> void:
	recipe_menu.open(recipe, screen_pos)
	if not _stack.has(recipe_menu):
		_stack.append(recipe_menu)

func open_item(item: Item, screen_pos: Vector2) -> void:
	item_menu.open(item, screen_pos)
	if not _stack.has(item_menu):
		_stack.append(item_menu)

func close_top() -> void:
	if _stack.is_empty():
		return
	_stack.pop_back()._play_close_tween()

func close_all() -> void:
	if _stack.is_empty():
		return
	while not _stack.is_empty():
		_stack.pop_back()._play_close_tween()
