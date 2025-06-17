class_name ValueQuestStep
extends QuestStep

# Name of the Dialogic variable that we are tracking
@export var target_value: String = ""


# If the objective is activated, check the target value
# to see if it has already reached the goal or not
func set_active(val: bool):
	super.set_active(val)
	if is_active:
		check_value()


func check_value():
	if is_active:
		var value = Dialogic.VAR[target_value]
		print("Objective check val: " + str(value))
		if int(value) >= goal:
			progress = goal
			is_completed = true
			is_active = false
		else:
			progress = int(value)
			progressed.emit()
