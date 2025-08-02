## This condition is met when the player donates food
class_name EventConditionStructureUnlocked
extends EventConditionSignal

@export_enum("Compost bin", "Picnic Table", "Raised bed", "Rain barrel", "Vertical garden",
"Recycling station", "Solar panel", "Waste bin", "Donation box",
"Food stand") var structure_name: String

func _init() -> void:
	await Engine.get_main_loop().process_frame
	_signal = StructureManager.structure_unlocked
	_expected_args = [structure_name]
	subscribe()
