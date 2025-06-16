class_name BuildHoverDetailContainer
extends PanelContainer

const ICON_COMPOST_BIN_LARGE = preload("res://assets/2d/ui/build_main_icons/icon-compost-bin-118px.png")
const ICON_PICNIC_TABLE_LARGE = preload("res://assets/2d/ui/build_main_icons/icon-picnic-table-118px.png")
const ICON_RAISED_BED_LARGE = preload("res://assets/2d/ui/build_main_icons/icon-raised-bed-118px.png")
const ICON_SOLAR_PANEL_LARGE = preload("res://assets/2d/ui/build_main_icons/icon-solar-panel-118px.png")
const ICON_VERTICAL_PLANTER_LARGE = preload("res://assets/2d/ui/build_main_icons/icon-vertical-planter-118px.png")
const ICON_WATER_BARREL_LARGE = preload("res://assets/2d/ui/build_main_icons/icon-water-barrel-118px.png")

static var structure_large_icons: Dictionary[String, Texture2D] = {
	"Compost bin": ICON_COMPOST_BIN_LARGE,
	"Picnic table": ICON_PICNIC_TABLE_LARGE,
	"Raised bed": ICON_RAISED_BED_LARGE,
	"Solar panel": ICON_SOLAR_PANEL_LARGE,
	"Vertical garden": ICON_VERTICAL_PLANTER_LARGE,
	"Rain barrel": ICON_WATER_BARREL_LARGE,
}

@export var structure_id: int
@export var title: String = ""
@export var description: String = ""
@export var icon_texture: Texture2D

@onready var title_label: Label = %TitleLabel
@onready var description_label: Label = %DescriptionLabel
@onready var icon_texture_rect: TextureRect = %IconTextureRect

func _ready() -> void:
	hide()
	#if structure_id:
		#show_preview(structure_id)
	#update_content(title, description, icon_texture)

func update_content(new_title: String, new_description: String, new_icon: Texture2D) -> void:
	title_label.text = new_title
	description_label.text = new_description
	icon_texture_rect.texture = new_icon

func show_preview(structure_id: int) -> void:
	var data = StructureManager.structure_data[structure_id]
	var name = StructureManager.structure_data[structure_id][StructureManager.StructureFields.STRUCTURE_NAME]
	var desc = StructureManager.structure_data[structure_id][StructureManager.StructureFields.STRUCTURE_DESCRIPTION]
	var icon = structure_large_icons.get(name, null)

	if icon == null:
		push_warning("No icon found for: '%s'" % name)

	update_content(name, desc, icon)
	show()
