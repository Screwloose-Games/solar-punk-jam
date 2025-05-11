class_name DailySummaryItemUi
extends HBoxContainer

@onready var reward_icon_large: RewardIconLarge = %RewardIconLarge
@onready var reward_label: Label = %RewardLabel
@onready var count_label: Label = %CountLabel

@export var item_name: String:
	set(value):
		item_name = value
		rerender()

@export var count: int:
	set(value):
		count = value
		rerender()

func _ready() -> void:
	rerender()

func rerender() -> void:
	if is_inside_tree():
		reward_icon_large.reward_name = item_name
		reward_label.text = item_name
		count_label.text = str(count)
