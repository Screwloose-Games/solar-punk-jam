extends Resource
class_name QuestObjective

@export var description : String = "Objective Description"
@export var linked_event : String = ""
@export var count : int = 0
@export var prerequisites : Array[int] = []
var progress : int = 0 : set = set_progress
var is_unlocked : bool = false
var is_active : bool = false
var is_completed : bool = false

signal completed


# Setter for progress, check for completion when value changes
# If completed, toggle flags and emit signal to notify parent Quest
func set_progress(val):
	print("Increment objective: " + description)
	progress = clamp(val, 0, count)
	if progress == count:
		is_active = false
		is_completed = true
		completed.emit()
