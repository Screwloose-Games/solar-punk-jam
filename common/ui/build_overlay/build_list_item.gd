class_name BuildLineItem
extends Button

const ICON_COMPOST_BIN_SMALL = preload("res://assets/2d/ui/build_small_icons/icon-compost-bin-25px.png")
const ICON_PICNIC_TABLE_SMALL = preload("res://assets/2d/ui/build_small_icons/icon-picnic-table-25px.png")
const ICON_RAISED_BED_SMALL = preload("res://assets/2d/ui/build_small_icons/icon-raised-bed-25px.png")
const ICON_SOLAR_PANEL_SMALL = preload("res://assets/2d/ui/build_small_icons/icon-solar-panel-25px.png")
const ICON_VERTICAL_PLANTER_SMALL = preload("res://assets/2d/ui/build_small_icons/icon-vertical-planter-25px.png")
const ICON_WATER_BARREL_SMALL = preload("res://assets/2d/ui/build_small_icons/icon-water-barrel-25px.png")

static var structure_small_icons = {
	"Compost bin": ICON_COMPOST_BIN_SMALL,
	"Picnic table": ICON_PICNIC_TABLE_SMALL,
	"Raised bed": ICON_RAISED_BED_SMALL,
	"Solar panel": ICON_SOLAR_PANEL_SMALL,
	"Vertical garden": ICON_VERTICAL_PLANTER_SMALL,
	"Rain barrel": ICON_WATER_BARREL_SMALL,
}

@export var structure_id: int

@export var disabled_style: StyleBoxFlat
@export var enabled_style: StyleBoxFlat

func _ready() -> void:
	ResourcesManager.updated_available_resources.connect(_on_resources_available_changed)
	var data = StructureManager.structure_data[structure_id]
	var name = StructureManager.structure_data[structure_id][StructureManager.StructureFields.STRUCTURE_NAME]
	var structure_name: String = name
	if structure_small_icons.has(name):
		icon = structure_small_icons[name]
	text = name

func _on_resources_available_changed():
	var data = StructureManager.structure_data[structure_id]
	var mats_required = StructureManager.structure_data[structure_id][StructureManager.StructureFields.MATERIAL_COST]
	var can_afford = ResourcesManager.has_at_least(ResourcesManager.ResourceType.MATERIALS, mats_required)
	disabled = !can_afford
