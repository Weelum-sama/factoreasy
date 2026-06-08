extends Control

@onready var facility_icon: TextureRect = %FacilityIcon
@onready var name_label: Label = %NameLabel

func setup(facility_data: FacilityData) -> void:
	if not facility_data:
		return
	facility_icon.texture = facility_data.texture
	name_label.text = facility_data.display_name
	
	if facility_data is ProcessingFacilityData:
		pass # instantiate recipe items
