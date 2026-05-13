# belt_tilemap.gd
var tiles: Dictionary = {}  # Vector2i -> BeltTile

var belt_speed : float = 1.0

func place_tile(cell: Vector2i, dir: Vector2i):
	var t = BeltTile.new()
	t.direction = dir
	tiles[cell] = t

func _process(delta):
	for cell in tiles:
		_tick_tile(cell, delta)

func _tick_tile(cell: Vector2i, delta: float):
	var tile = tiles[cell]
	if tile.item == null:
		return
	tile.progress += belt_speed * delta
	if tile.progress < 1.0:
		return
	tile.progress = 0.0
	var next_cell = cell + tile.direction
	if tiles.has(next_cell) and tiles[next_cell].item == null:
		tiles[next_cell].item = tile.item
		tile.item = null
	# else: belt is blocked, item stays put
