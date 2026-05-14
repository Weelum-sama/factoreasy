
var unlocked_buildings: Dictionary = {
	"extractor":	true,
	"conveyor":		true,
	"sink":			true,
	"smelter":		false,
	"constructor":	false,
}

signal building_unlocked(building_id: String)

func unlock_building(building_id: String) -> void:
	if unlocked_buildings.has(building_id):
		unlocked_buildings[building_id] = true
		building_unlocked.emit("building_unlocked" ,building_id)

func is_building_unlocked(building_id: String) -> bool:
	return unlocked_buildings.get(building_id, false)
