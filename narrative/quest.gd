extends Resource
class_name Quest

@export var name : String = "Quest Name"
@export var quest_giver : String = "npc_name"
@export var description : String = "Quest Description"
@export var objectives : Array[QuestObjective] = []
@export var unlock_structure : String = ""
@export var rewards : Dictionary = {
	"Happiness" : 5
}

var is_complete : bool = false

signal quest_state_changed
signal quest_completed(giver : String)


# Initialize quest state
# Objectives with no prerequisites get set active
func start_quest():
	Dialogic.VAR[quest_giver + "_active"] = true
	if unlock_structure != "":
		StructureManager.register_structure(unlock_structure)
	for i in objectives.size():
		if objectives[i].prerequisites.is_empty():
			objectives[i].is_unlocked = true
			objectives[i].is_active = true


func check_progress():
	if !is_complete:
		for objective in objectives:
			if objective.is_active:
				var check_value = Dialogic.VAR[objective.quest_value]
				print("Objective check val: " + str(check_value))
				if typeof(check_value) not in [TYPE_BOOL, TYPE_INT]:
					print("Value is not int or bool, aborting check.")
				else:
					if int(check_value) >= objective.goal:
						objective.progress = objective.goal
						objective.is_completed = true
						objective.is_active = false
						_on_objective_completed()
					else:
						objective.progress = int(check_value)
						quest_state_changed.emit()


# If an objective is completed, check if the overall quest is completed too
func _on_objective_completed():
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
	var complete_check = true
	for objective in objectives:
		if !objective.is_completed:
			complete_check = false
	if complete_check:
		is_complete = true
		for reward in rewards.keys():
			EnvironmentManager.gain_resource(reward, rewards[reward])
		quest_completed.emit(quest_giver)
	else:
		quest_state_changed.emit()
