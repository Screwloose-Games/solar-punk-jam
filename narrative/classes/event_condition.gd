class_name EventCondition
extends Resource

signal occured

var has_occured: bool = false

## The condition has been met. It assumes must occur only once, then condition is met permanently.
var is_met: bool:
	get:
		return has_occured


func event_occured():
	if has_occured:
		return
	else:
		has_occured = true
		occured.emit()
