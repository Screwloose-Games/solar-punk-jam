extends Resource
class_name QuestObjective

@export var description : String = "Objective Description"
@export var quest_value : String = ""
@export var goal : int = 1
@export var prerequisites : Array[int] = []
@export var play_dialogue : String = ""

var progress : int = 0
var is_active : bool = false
var is_unlocked : bool = false
var is_completed : bool = false
