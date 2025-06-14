extends Resource
class_name Quest

signal quest_state_changed
signal quest_completed(giver : String)

@export var id : String = "quest_id"
@export var name : String = "Quest Name"
@export var quest_giver : String = "npc_name"
@export var description : String = "Quest Description"
@export_multiline var community_board_text : String = "" # displayed on the community board
@export var objectives : Array[QuestObjective] = []
@export var unlock_on_accept : Array[String]
@export var unlock_on_complete : Array[String]
@export var resource_rewards: Dictionary[ResourcesManager.ResourceType, int] = {
	ResourcesManager.ResourceType.HAPPINESS : 5
}
@export var on_complete_starts_quest: Quest


var is_active: bool = false
var is_complete : bool = false

var rewards: Dictionary[String, int] = {}:
	get:
		var result: Dictionary[String, int] = {}
		for reward in resource_rewards:
			var _name: String = ResourcesManager.RESOURCE_TYPE_NAMES[reward]
			result[_name] = resource_rewards[reward]
		return result

# Initialize quest state
# Objectives with no prerequisites get set active
func start_quest():
	Dialogic.VAR[id] = true
	Dialogic.VAR[quest_giver + "_active"] = true
	for structure in unlock_on_accept:
		StructureManager.register_structure(structure)
	for objective in objectives:
		objective.completed.connect(_on_objective_completed)
		if objective.prerequisites.is_empty():
			objective.is_unlocked = true
			objective.is_active = true


func check_progress():
	if !is_complete:
		for objective in objectives:
			if objective is ValueQuestObjective:
				objective.check_value()


# If an objective is completed, check if the overall quest is completed too
func _on_objective_completed(this_objective : QuestObjective):
	if this_objective.play_dialogue != "":
		Dialogic.start(id, this_objective.play_dialogue)
	# Check for objectives with prereqs
	for objective in objectives:
		if !objective.prerequisites.is_empty():
			if !objective.is_completed and !objective.is_active:
				var complete_check = true
				for i in objective.prerequisites:
					if !objectives[i].is_completed:
						complete_check = false
				if complete_check:
					objective.is_unlocked = true
					objective.is_active = true
	# Check for overall completion
	var all_complete = true
	var progress = 0
	for objective in objectives:
		if !objective.is_completed:
			all_complete = false
		else:
			progress += 1
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
	if on_complete_starts_quest:
		QuestManager.start_quest_resource(on_complete_starts_quest)

func get_next_step() -> QuestObjective:
	for objective in objectives:
		if objective.is_unlocked and !objective.is_completed:
			return objective
	return null

func complete_next_step() -> void:
	var next_step = get_next_step()
	if next_step:
		next_step.set_complete(true)

func reset():
	is_active = false
	is_complete = false
	for objective in objectives:
		objective.reset()
	