extends Resource
class_name QuestObjective

@export var description : String = "Objective Description"
@export var linked_event : String = ""
@export var event_param : String = ""
@export var count : int = 0
@export var prerequisites : Array[int] = []
var progress : int = 0 : set = set_progress
var is_active : bool = false : set = set_active
var is_unlocked : bool = false
var is_completed : bool = false

signal progress_changed
signal completed


# Setter for progress, check for completion when value changes
# If completed, toggle flags and emit signal to notify parent Quest
func set_progress(val : int):
	print("Increment objective: " + description)
	progress = clamp(val, 0, count)
	if progress == count:
		is_active = false
		is_completed = true
		completed.emit()
	else:
		progress_changed.emit()


func set_active(val : bool):
	is_active = val
	if is_active:
		GlobalSignalBus.connect(linked_event, _on_linked_event)
	else:
		GlobalSignalBus.disconnect(linked_event, _on_linked_event)


func _on_linked_event(signal_param : String = "none"):
	if is_active:
		print("Objective signal fired. Name: %s Param: %s" % [linked_event, signal_param])
		if event_param == "":
			print("Event param not specified, incrementing progress.")
			progress += 1
		elif signal_param == event_param:
			print("Event param match, incrementing progress.")
			progress += 1
		else:
			print("Event param mis-match, will not increment progress.")
