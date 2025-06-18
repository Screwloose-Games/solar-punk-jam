class_name QuestStepHaveResource
extends QuestStep
## HAVE_RESOURCE quest step
## Used for when a certain amount of a certain resource must be available

## Type of resource to have
@export var resource : ResourcesManager.ResourceType
## Amount of resource to have
@export var amount : int = 1


func set_active(val: bool):
	_signal = ResourcesManager.updated_available_resources
	_expected_args = []
	goal = amount
	super.set_active(val)


func event_occured():
	if is_completed:
		return
	check_value()


func check_value():
	if is_active:
		var value = ResourcesManager.get_resource_count(resource)
		print("Objective check val: " + str(value))
		if int(value) >= goal:
			progress = goal
			is_completed = true
			is_active = false
		else:
			progress = int(value)
			progressed.emit()
