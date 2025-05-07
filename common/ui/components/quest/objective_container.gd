extends HBoxContainer

@onready var complete = $Complete
@onready var desc = $Description

var objective : QuestObjective : set = set_objective


func set_objective(val):
	objective = val
	update()


func update():
	complete.button_pressed = objective.is_completed
	desc.text = "%s : %d / %d" % [objective.description, objective.progress, objective.goal]
	visible = objective.is_unlocked
