class_name Quest
extends Resource
## Quest class
## Used to describe and outline tasks for the player to do as part of a quest in game

signal quest_became_available
signal quest_state_changed
signal quest_completed(giver: String)

enum QuestState {UNAVAILABLE, AVAILABLE, ACTIVE, COMPLETE}

@export var id: String = "quest_id"
@export var name: String = "Quest Name"

## The character who you can interact with to aquire the quest, or null if it's from the board
@export var giver: DialogicCharacter

@export var description: String = "Quest Description"
@export_multiline var community_board_text: String = ""  # displayed on the community board
@export_custom(PROPERTY_HINT_ENUM_SUGGESTION,"Compost bin,Picnic table,Raised bed,Rain barrel,Vertical garden,Recycling station,Solar panel,Waste bin,Donation box,Food stand")
var unlock_on_accept: Array[String]

## The contitions under which this quest becomes available from the giver of the quest.
@export var unlock_conditions: Array[EventCondition]
@export var steps: Array[QuestStep] = []

@export_category("When complete")
@export_custom(PROPERTY_HINT_ENUM_SUGGESTION,"Compost bin,Picnic table,Raised bed,Rain barrel,Vertical garden,Recycling station,Solar panel,Waste bin,Donation box,Food stand")
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

## The dialogue to play just before starting the quest
@export var prologue: DialogicTimeline


var quest_giver: String:
	get:
		if giver:
			return giver.display_name.to_lower()
		return "board"

var state: QuestState = QuestState.UNAVAILABLE
var pinned : bool = false
#var is_active: bool = false
var is_complete: bool = false:
	get:
		return state == QuestState.COMPLETE

var rewards: Dictionary[String, int] = {}:
	get:
		var result: Dictionary[String, int] = {}
		for reward in resource_rewards:
			var reward_name: String = ResourcesManager.RESOURCE_TYPE_NAMES[reward]
			result[reward_name] = resource_rewards[reward]
		return result

var is_unlocked: bool:
	get:
		return state != QuestState.UNAVAILABLE


func _init() -> void:
	await Engine.get_main_loop().process_frame # Required for @export values to populate
	init_unlocking()

func _on_unlock_condition_occured():
	if unlock_conditions.all(func(condition: EventCondition): return condition.is_met):
		unlock()


func init_unlocking():
	for condition in unlock_conditions:
		if not condition.occured.is_connected(_on_unlock_condition_occured):
			condition.occured.connect(_on_unlock_condition_occured)
	
# Initialize quest state, steps with no prerequisites get set active
func start_quest():
	if prologue:
		Dialogic.start(prologue)
		await Dialogic.timeline_ended
	Dialogic.VAR[id] = true
	state = QuestState.ACTIVE
	for structure in unlock_on_accept:
		StructureManager.register_structure(structure)
	for step in steps:
		if !step.completed.is_connected(_on_step_completed):
			step.completed.connect(_on_step_completed)
		if step.prerequisites.is_empty():
			step.is_unlocked = true
			step.is_active = true


func check_progress():
	if state == QuestState.ACTIVE:
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
	state = QuestState.COMPLETE
	for structure in unlock_on_complete:
		StructureManager.register_structure(structure)
	for reward in rewards.keys():
		ResourcesManager.gain_resource_str(reward, rewards[reward])
	quest_completed.emit(quest_giver)
	if next_quest:
		QuestManager.start_quest_resource(next_quest)


## Makes the quest avialble from the quest_giver
func unlock():
	if state == QuestState.UNAVAILABLE:
		state = QuestState.AVAILABLE
		quest_state_changed.emit()
		quest_became_available.emit()
		QuestManager.unlock_quest_res(self)


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
	state = QuestState.AVAILABLE
	for step in steps:
		step.reset()
