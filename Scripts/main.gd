extends Node2D

func _ready() -> void:
	GameState.game_paused.connect(_on_pause)
	GameState.grid_load_requested.connect(_restore_grid)

func _on_pause(paused: bool) -> void:
	var pause_menu: PauseMenu = $PauseMenu
	if not pause_menu:
		return
	
	if paused:
		pause_menu.show_menu()
	else:
		pause_menu.hide_menu()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Escape"):
		GameState.game_paused.emit(!get_tree().paused)

func _restore_grid(grid_data: GridData) -> void:
	var belt_scene: PackedScene = preload("res://Objects/Scenes/Facilities/belt.tscn")
	var ore_node_scene: PackedScene = preload("res://Objects/Scenes/Ore Nodes/ore_node.tscn")
	
	for entry in grid_data.entries:
		var cell: Vector2i	= entry["cell"]
		var saved_rotation: float	= entry["rotation"]
		var type: String	= entry["type"]
		
		var node: Node2D
		
		if type == "belt":
			node = belt_scene.instantiate()
		elif GameState.facility_registry.get(type) is OreNodeData:
			var ore_data: OreNodeData = GameState.facility_registry[type]
			node = ore_node_scene.instantiate()
			node.data = ore_data
		else:
			var facility_data: FacilityData = GameState.facility_registry.get(type)
			if not facility_data or not facility_data.scene:
				push_warning("No scene found for saved type: " + type)
				continue
			node = facility_data.scene.instantiate()
			
		node.rotation = saved_rotation
		add_child(node)
		GridManager.place(cell, node)
		
		if node is Belt:
			BeltManager.register_belt(cell, node)
