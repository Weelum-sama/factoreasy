extends CanvasLayer
class_name ContextMenuLayer

@onready var belt_menu: BeltContextMenu = $BeltContextMenu
@onready var facility_menu: FacilityContextMenu = $FacilityContextMenu
@onready var recipe_menu: RecipeContextMenu = $RecipeContextMenu
@onready var item_menu: ItemContextMenu     = $ItemContextMenu

var _stack_order: Array[ContextMenuBase] = []

func _ready() -> void:
	close_all()
	_stack_order = [facility_menu, belt_menu, recipe_menu, item_menu]
	_stack_order.reverse()
	GameState.game_paused.connect(func(paused: bool) -> void:
		if paused: close_all()
	)

func open_for(node: Node, screen_pos: Vector2) -> void:
	close_all()
	if node is Belt:
		belt_menu.open(node as Belt, screen_pos)
	elif node is BaseFacility:
		facility_menu.open(node as BaseFacility, screen_pos)

func open_recipe(recipe: Recipe, screen_pos: Vector2) -> void:
	recipe_menu.open(recipe, screen_pos)

func open_item(item: Item, screen_pos: Vector2) -> void:
	item_menu.open(item, screen_pos)

func close_top() -> void:
	for menu in _stack_order.filter(func(c): return c.scale == Vector2(1.0, 1.0)):
		menu._play_close_tween(menu)
		return

func close_all() -> void:
	for child in get_children():
		if child is Control and (child as Control).scale > Vector2(0.1, 0.1):
			(child as ContextMenuBase)._play_close_tween(child)

func any_open() -> bool:
	for child in get_children():
		if child is Control and child.visible:
			return true
	return false
