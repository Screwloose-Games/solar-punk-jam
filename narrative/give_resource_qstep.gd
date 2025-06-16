class_name GiveResourceQuestStep
extends SignalQuestStepBase

@export var recipient: String
@export var resource: ResourcesManager.ResourceType

func set_active(val: bool):
	_signal = GlobalSignalBus.resource_given
	_expected_args = [recipient, resource]
	super.set_active(val)
