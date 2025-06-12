class_name EnterAreaQuestStep 
extends SignalQuestStep

@export var area_id : String
@export var start_time : int = 0
@export var end_time : int = 0

# QuestStepArea3D has an id String field.
# EnteredAreaQuestStep has an id String field.
# Must work when standing in area ahead of time
# Must work when entering the area within the time frameq
# Either neither or both start and end time must be configured or throws editor error

func set_active(val : bool):
	autoload_name = "GlobalSignalBus"
	signal_name = "quest_area_entered"
	expected_args = [area_id]
	super.set_active(val)
