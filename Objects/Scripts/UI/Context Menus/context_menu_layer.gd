extends CanvasLayer
class_name ContextMenuLayer

@onready var belt_menu: BeltContextMenu = $BeltContextMenu
@onready var facility_menu: FacilityContextMenu = $FacilityContextMenu
@onready var recipe_menu: RecipeContextMenu = $RecipeContextMenu
@onready var item_menu: ItemContextMenu     = $ItemContextMenu

func _ready() -> void:
	close_all()
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

func close_all() -> void:
	for child in get_children():
		if child is Control:
			child.visible = false

func any_open() -> bool:
	for child in get_children():
		if child is Control and child.visible:
			return true
	return false
