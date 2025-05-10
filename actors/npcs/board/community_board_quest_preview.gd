class_name CommunityBoardCanvasLayer
extends CanvasLayer

@onready var header : Label = %Header
@onready var body : Label = %Body
@onready var objectives : Label = %Objectives
@onready var accept_button: Button = %AcceptButton
@onready var close_button: Button = %CloseButton
@onready var mini_rewards_h_box_container: MiniRewardsHBoxContainer = %MiniRewardsHBoxContainer
@onready var quest_rewards_row_large: HBoxContainer = %QuestRewardsRowLarge
@onready var reward_icon_large: RewardIconLarge = %RewardIconLarge

var quest: Quest:
	set(val):
		quest = val
		if not is_node_ready():
			await ready
		rerender()

signal quest_accepted
signal closed


func _ready() -> void:
	accept_button.pressed.connect(emit_signal.bind("quest_accepted"))
	visibility_changed.connect(_on_visibility_changed)
	close_button.pressed.connect(emit_signal.bind("closed"))


func _on_visibility_changed():
	if visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _update_rewards_large() -> void:
	for child in quest_rewards_row_large.get_children():
		if child != reward_icon_large:
			child.queue_free()

	#for resource_name in quest.rewards.keys():
		#var reward_instance = reward_icon_large.duplicate()
		#reward_instance.reward_name = resource_name
		#reward_instance.show()
		#quest_rewards_row_large.add_child(reward_instance)
	for structure in quest.unlock_on_accept:
		var reward_instance = reward_icon_large.duplicate()
		reward_instance.reward_name = structure
		reward_instance.show()
		quest_rewards_row_large.add_child(reward_instance)
	for structure in quest.unlock_on_complete:
		var reward_instance = reward_icon_large.duplicate()
		reward_instance.reward_name = structure
		reward_instance.show()
		quest_rewards_row_large.add_child(reward_instance)
		
func rerender():
	header.text = quest.name
	body.text = quest.community_board_text
	var obj_text = ""
	for objective in quest.objectives:
		obj_text += objective.description + "\n"
	objectives.text = obj_text
	_update_rewards_large()
	mini_rewards_h_box_container.quest_rewards = quest.rewards
