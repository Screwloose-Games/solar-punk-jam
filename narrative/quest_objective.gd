extends Resource
class_name QuestObjective

@export var description : String = "Objective Description"
@export var goal : int = 1
@export var prerequisites : Array[int] = []
@export var play_dialogue : String = ""

var progress : int = 0
var is_active : bool = false : set = set_active
var is_unlocked : bool = false
var is_completed : bool = false : set = set_complete

signal progressed
signal completed(this_objective : QuestObjective)


func set_active(val : bool):
	is_active = val


func set_complete(val : bool):
	is_completed = val
	if is_completed:
		completed.emit(self)
