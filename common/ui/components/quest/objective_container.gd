extends HBoxContainer

@onready var complete = $Complete
@onready var desc = $Description

var step : QuestStep : set = set_step


func set_step(val):
	step = val
	update()


func update():
	step.button_pressed = step.is_completed
	desc.text = "%s : %d / %d" % [step.description, step.progress, step.goal]
	visible = step.is_unlocked
