class_name QuestStepGiveResource
extends QuestStep
## GIVE_RESOURCE quest step
## Used when the player must give a certain resource to a certain NPC

## ID string of the receiving NPC
@export var recipient: String
## Type of resource to be given
@export var resource: ResourcesManager.ResourceType


func set_active(val: bool):
	_signal = GlobalSignalBus.resource_given
	_expected_args = [recipient, resource]
	super.set_active(val)
