class_name QuestStepGiveItem
extends QuestStep
## GIVE_ITEM quest step
## Used when the player must give a certain item to a certain NPC

## ID string of the NPC getting the item
@export var recipient: String
## ID string of the item to be given
@export var item: String


func set_active(val: bool):
	_signal = GlobalSignalBus.item_given
	_expected_args = [recipient, item]
	super.set_active(val)
