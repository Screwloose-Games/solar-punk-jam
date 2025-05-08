class_name MiniSingleRewardItemHBoxContainer
extends HBoxContainer

const ICON_RADISH_20_PX = preload("res://assets/2d/ui/icon-radish-20px.png")
const ICON_MATERIAL_20_PX = preload("res://assets/2d/ui/icon-material-20px.png")
const ICON_SEED_RADISH_20_PX = preload("res://assets/2d/ui/icon-seed-radish-20px.png")
const ICON_SEED_STRAWBERRY_20_PX = preload("res://assets/2d/ui/icon-seed-strawberry-20px.png")
const ICON_SOIL_20_PX = preload("res://assets/2d/ui/icon-soil-20px.png")
const ICON_WASTE_20_PX = preload("res://assets/2d/ui/icon-waste-20px.png")
const ICON_WATER_20_PX = preload("res://assets/2d/ui/icon-water-20px.png")
const HAPPINESS_ICON = preload("res://assets/2d/ui/Happiness-icon.png")


static var resource_icons = {
	"Materials": ICON_MATERIAL_20_PX,
	"Seeds": ICON_SEED_RADISH_20_PX,  # Or swap with strawberry depending on preference
	"Soil": ICON_SOIL_20_PX,
	"Waste": ICON_WASTE_20_PX,
	"Water": ICON_WATER_20_PX,
	"Electricity": null,
	"Food": ICON_RADISH_20_PX,
	"Happiness": null,
	"Environment": null
}

@export_enum("Electricity", "Water", "Food", "Waste", "Soil", "Happiness", "Materials", "Seeds", "Environment") var reward_name: String = "Soil"
@export var count: int = 1

@onready var mini_reward_icon: TextureRect = %MiniRewardIcon
@onready var mini_reward_label: Label = %MiniRewardLabel
#@onready var mini_reward_count_plus_label: Label = %MiniRewardCountPlusLabel
@onready var mini_reward_count_amount_label: Label = %MiniRewardCountAmountLabel

func _ready() -> void:
	_update_display()

func _update_display() -> void:
	var icon = resource_icons.get(reward_name, null)
	if icon:
		mini_reward_icon.texture = icon
	#else:
		#mini_reward_icon.texture = null

	mini_reward_label.text = reward_name
	#mini_reward_count_plus_label.text = "+"
	mini_reward_count_amount_label.text = str(count)
