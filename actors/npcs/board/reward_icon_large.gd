class_name RewardIconLarge
extends TextureRect

const REWARD_COMPOST_BIN_ICON = preload("res://assets/2d/ui/reward-compost-bin-icon.png")
const REWARD_JUNK = preload("res://assets/2d/ui/reward-Junk.png")
const REWARD_MATERIALS = preload("res://assets/2d/ui/reward-Materials.png")
const REWARD_PICNIC_TABLE_ICON = preload("res://assets/2d/ui/reward-picnic-table-icon.png")
const REWARD_RADISH_ICON = preload("res://assets/2d/ui/reward-radish-icon.png")
const REWARD_RAISED_BED_ICON = preload("res://assets/2d/ui/reward-raised-bed-icon.png")
const REWARD_SEEDS_RADISH = preload("res://assets/2d/ui/reward-Seeds-Radish.png")
const REWARD_SEEDS_STRAWBERRY = preload("res://assets/2d/ui/reward-Seeds-Strawberry.png")
const REWARD_SOIL = preload("res://assets/2d/ui/reward-Soil.png")
const REWARD_SOLAR_PANNEL_ICON = preload("res://assets/2d/ui/reward-solar-pannel-icon.png")
const REWARD_STRAWBERRY_ICON = preload("res://assets/2d/ui/reward-strawberry-icon.png")
const REWARD_VERTICAL_PALNTER_ICON = preload("res://assets/2d/ui/reward-vertical-palnter-icon.png")
const REWARD_WATER_BARREL = preload("res://assets/2d/ui/reward-water-barrel.png")

const TEMP_ICON = preload("res://assets/2d/ui/Happiness-icon.png")

static var quest_reward_icons = {
	"Materials": REWARD_MATERIALS,
	"Soil": REWARD_SOIL,
	"Junk": REWARD_JUNK,
	"Compost bin": REWARD_COMPOST_BIN_ICON,
	"Picnic table": REWARD_PICNIC_TABLE_ICON,
	"Radish": REWARD_RADISH_ICON,
	"Raised bed": REWARD_RAISED_BED_ICON,
	"Seeds (Radish)": REWARD_SEEDS_RADISH,
	"Seeds (Strawberry)": REWARD_SEEDS_STRAWBERRY,
	"Solar panel": REWARD_SOLAR_PANNEL_ICON,
	"Strawberry": REWARD_STRAWBERRY_ICON,
	"Vertical planter": REWARD_VERTICAL_PALNTER_ICON,
	"Water barrel": REWARD_WATER_BARREL,
}

@export var reward_name: String

func _ready() -> void:
	if reward_name in quest_reward_icons:
		texture = quest_reward_icons[reward_name]
	else:
		texture = TEMP_ICON
		push_warning("No icon found for reward: '%s'" % reward_name)
		#visible = false
