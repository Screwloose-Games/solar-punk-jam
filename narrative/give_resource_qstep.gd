class_name GiveResourceQuestStep
extends SignalQuestStep

@export var recipient : String
@export var resource : String


func set_active(val : bool):
	autoload_name = "GlobalSignalBus"
	signal_name = "resource_given"
	expected_args = [recipient, resource]
	super.set_active(val)
