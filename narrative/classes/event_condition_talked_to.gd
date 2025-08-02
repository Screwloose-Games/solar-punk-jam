## This condition is met when the player donates food
class_name EventConditionTalkedTo
extends EventConditionSignal

@export var character: DialogicCharacter

func _init() -> void:
	await Engine.get_main_loop().process_frame
	_signal = GlobalSignalBus.talked_to_character
	_expected_args = [character]
	subscribe()
