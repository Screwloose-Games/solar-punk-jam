class_name EnterAreaQuestStep 
extends SignalQuestStep

@export var area_id : String


func set_active(val : bool):
	autoload_name = "GlobalSignalBus"
	signal_name = "quest_trigger_area_entered"
	expected_args = [area_id]
	super.set_active(val)
