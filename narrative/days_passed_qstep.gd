class_name DaysPassedQuestStep
extends SignalQuestStep


func set_active(val : bool):
	autoload_name = "EnvironmentManager"
	signal_name = "day_passed"
	expected_args = []
	super.set_active(val)
