extends HBoxContainer

var step: QuestStep:
	set = set_step

@onready var complete = $Complete
@onready var desc = $Description


func set_step(val):
	step = val
	update()


func update():
	complete.button_pressed = step.is_completed
	if step.goal == 1:
		desc.text = step.description
	else:
		desc.text = "%s : %d / %d" % [step.description, step.progress, step.goal]
	visible = step.is_unlocked
