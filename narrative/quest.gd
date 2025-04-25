extends Resource
class_name Quest

@export var name : String = "Quest Name"
@export var description : String = "Quest Description"
@export var objectives : Array[QuestObjective] = []
var is_complete : bool = false

signal quest_state_changed
signal quest_completed


# Initialize quest state
# Connect signal from GlobalSignalBus to event handler
# Objectives with no prerequisites get set active
func start_quest():
	for i in objectives.size():
		objectives[i].completed.connect(_on_objective_completed)
		GlobalSignalBus.connect(
			objectives[i].linked_event,
			_on_objective_signal.bind(objectives[i].linked_event))
		if objectives[i].prerequisites.is_empty():
			objectives[i].is_unlocked = true
			objectives[i].is_active = true


# Update the quest status
# This is a separate function to be run AFTER the event handler increments progress
# This is done to avoid objective completion edge cases
func update_status():
	for objective in objectives:
		var complete_check = true
		if !objective.is_completed and !objective.is_active:
			for i in objective.prerequisites:
				if !objectives[i].is_completed:
					complete_check = false
		if complete_check:
			objective.is_active = true
			objective.is_unlocked = true
	quest_state_changed.emit()


# Increment progress on active objectives if we hear the associated signal
# If an increment was done, update our status
func _on_objective_signal(signal_name : String):
	print("Objective signal fired")
	var has_changed = false
	for objective in objectives:
		if objective.is_active and objective.linked_event == signal_name:
			objective.progress += 1
			has_changed = true
	if has_changed:
		update_status()


# If an objective is completed, check if the overall quest is completed too
func _on_objective_completed():
	var complete_check = true
	for objective in objectives:
		if !objective.is_completed:
			complete_check = false
	if complete_check:
		is_complete = true
		quest_completed.emit()
	else:
		quest_state_changed.emit()
