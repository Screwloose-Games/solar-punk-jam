class_name HaveResourceQuestStep
extends ValueQuestStep

@export var resource_type: String


func check_value():
	if is_active:
		var check_value = ResourcesManager.get_resource_by_name(resource_type)
		print("Objective check val: " + str(check_value))
		if int(check_value) >= goal:
			progress = goal
			is_completed = true
			is_active = false
		else:
			progress = int(check_value)
			progressed.emit()
