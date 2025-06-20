class_name Quest
extends Resource
## Quest class
## Used to describe and outline tasks for the player to do as part of a quest in game

signal quest_state_changed
signal quest_completed(giver: String)

@export var id: String = "quest_id"
@export var name: String = "Quest Name"
@export_custom(PROPERTY_HINT_ENUM_SUGGESTION,"trin,kai,kelly,board,kyle,mister") var quest_giver: String = ""
# @export var quest_source: DialogicCharacter
@export var description: String = "Quest Description"
@export_multiline var community_board_text: String = ""  # displayed on the community board
@export_custom(PROPERTY_HINT_ENUM_SUGGESTION,"Compost bin,Picnic Table,Raised bed,Rain barrel,
Vertical garden,Recycling station,Solar panel,Waste bin,Donation box,Food stand")
var unlock_on_accept: Array[String]

@export var steps: Array[QuestStep] = []

@export_category("When complete")
@export_custom(PROPERTY_HINT_ENUM_SUGGESTION,"Compost bin,Picnic Table,Raised bed,Rain barrel,
Vertical garden,Recycling station,Solar panel,Waste bin,Donation box,Food stand")
var unlock_on_complete: Array[String]

@export var resource_rewards: Dictionary[ResourcesManager.ResourceType, int] = {
	ResourcesManager.ResourceType.HAPPINESS: 5
}
## Story variables to change as a result of completing this quest
#@export var change_story_variables: Dictionary[String, String]
## The next quest after this one
@export var next_quest: Quest

## Start the next quest automatically
@export var start_next_quest: bool = true

var is_active: bool = false
var is_complete: bool = false

var rewards: Dictionary[String, int] = {}:
	get:
		var result: Dictionary[String, int] = {}
		for reward in resource_rewards:
			var reward_name: String = ResourcesManager.RESOURCE_TYPE_NAMES[reward]
			result[reward_name] = resource_rewards[reward]
		return result


# Initialize quest state, steps with no prerequisites get set active
func start_quest():
	Dialogic.VAR[id] = true
	Dialogic.VAR[quest_giver + "_active"] = true
	for structure in unlock_on_accept:
		StructureManager.register_structure(structure)
	for step in steps:
		if !step.completed.is_connected(_on_step_completed):
			step.completed.connect(_on_step_completed)
		if step.prerequisites.is_empty():
			step.is_unlocked = true
			step.is_active = true


func check_progress():
	if !is_complete:
		for step in steps:
			step.check_value()


# If an step is completed, check if the overall quest is completed too
func _on_step_completed(this_step: QuestStep):
	if this_step.play_dialogue != "":
		Dialogic.start(id, this_step.play_dialogue)
	# Check for steps with prereqs
	for step in steps:
		if !step.prerequisites.is_empty():
			if !step.is_completed and !step.is_active:
				var complete_check = true
				for i in step.prerequisites:
					if !steps[i].is_completed:
						complete_check = false
				if complete_check:
					step.is_unlocked = true
					step.is_active = true
	# Check for overall completion
	var all_complete = true
	for step in steps:
		if !step.is_completed:
			all_complete = false
	if all_complete:
		mark_complete()
	else:
		quest_state_changed.emit()


func mark_complete():
	is_complete = true
	for structure in unlock_on_complete:
		StructureManager.register_structure(structure)
	for reward in rewards.keys():
		ResourcesManager.gain_resource_str(reward, rewards[reward])
	quest_completed.emit(quest_giver)
	if next_quest:
		QuestManager.start_quest_resource(next_quest)


func get_next_step() -> QuestStep:
	for step in steps:
		if step.is_unlocked and !step.is_completed:
			return step
	return null


func complete_next_step() -> void:
	var next_step = get_next_step()
	if next_step:
		next_step.set_complete(true)


func reset():
	is_active = false
	is_complete = false
	for step in steps:
		step.reset()
