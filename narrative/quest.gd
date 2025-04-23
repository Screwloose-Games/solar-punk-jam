extends Resource
class_name Quest

@export var name : String = "Quest Name"
@export var description : String = "Quest Description"
@export var objectives : Array[QuestObjective] = []

signal quest_state_changed
signal quest_completed


func start_quest():
	for i in objectives.size():
		objectives[i].completed.connect(_on_objective_completed)
		GlobalSignalBus.connect(
			objectives[i].linked_event,
			_on_objective_signal.bind(objectives[i].linked_event))
		if objectives[i].prerequisites.is_empty():
			objectives[i].is_active = true


func _on_objective_signal(signal_name : String):
	for objective in objectives:
		if objective.is_active and objective.linked_event == signal_name:
			objective.progress += 1
			quest_state_changed.emit()


func _on_objective_completed():
	var complete_check = true
	for objective in objectives:
		complete_check = objective.is_completed
		if !objective.is_completed and !objective.is_active:
			objective.is_active = true
			for i in objective.prerequisites:
				if !objectives[i].is_completed:
					objective.is_active = false
	if complete_check:
		quest_completed.emit()
	else:
		quest_state_changed.emit()
