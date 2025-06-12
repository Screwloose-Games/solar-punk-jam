class_name HaveStructQuestStep
extends ValueQuestStep

@export var structure_type : String


func check_value():
	if is_active:
		# Check if structure_type is in built_structures
		var check_value = StructureManager.built_structures
		print("Objective check val: " + str(check_value))
		if typeof(check_value) not in [TYPE_BOOL, TYPE_INT]:
			print("Value is not int or bool, aborting check.")
		else:
			if int(check_value) >= goal:
				progress = goal
				is_completed = true
				is_active = false
			else:
				progress = int(check_value)
				progressed.emit()
