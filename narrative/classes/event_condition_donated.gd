## This condition is met when the player donates food
class_name EventConditionDonatedFood
extends EventConditionSignal

func _init() -> void:
	_signal = GlobalSignalBus.food_donated
	subscribe()
