# HAVE_RESOURCE quest step
# Used for when a certain amount of a certain resource must be available
extends QuestStep
class_name QuestStepHaveResource

@export var resource : ResourcesManager.ResourceType
@export var amount : int = 1


func set_active(val: bool):
	_signal = ResourcesManager.UpdatedAvailableResources
	_expected_args = []
	goal = amount
	super.set_active(val)


func check_value():
	if is_active:
		var check_value = ResourcesManager.get_resource_count(resource)
		print("Objective check val: " + str(check_value))
		if int(check_value) >= goal:
			progress = goal
			is_completed = true
			is_active = false
		else:
			progress = int(check_value)
			progressed.emit()
