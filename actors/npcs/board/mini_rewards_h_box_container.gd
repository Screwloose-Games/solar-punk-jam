class_name MiniRewardsHBoxContainer
extends HBoxContainer

@export var quest_rewards: Dictionary[String, int] = {}:
	set(value):
		quest_rewards = value
		if not is_node_ready():
			await ready
		_update_rewards()

@onready var mini_single_reward_item_h_box_container: MiniSingleRewardItemHBoxContainer = %MiniSingleRewardItemHBoxContainer

func _ready() -> void:
	mini_single_reward_item_h_box_container.hide()
	if not is_node_ready():
		await ready
	_update_rewards()

func _update_rewards() -> void:
	for child in get_children():
		if child != mini_single_reward_item_h_box_container:
			child.queue_free()

	for resource_name in quest_rewards.keys():
		var count = quest_rewards[resource_name]
		var reward_instance = mini_single_reward_item_h_box_container.duplicate()
		reward_instance.show()
		reward_instance.reward_name = resource_name
		reward_instance.count = count
		add_child(reward_instance)
