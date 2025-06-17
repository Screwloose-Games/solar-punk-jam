class_name QuestStepGetItem
extends QuestStep
## GET_ITEM quest step
## Used when the player has to get a certain item

## ID string of the item to be taken
@export var item: String


func set_active(val: bool):
	_signal = GlobalSignalBus.item_received
	_expected_args = [item]
	super.set_active(val)
