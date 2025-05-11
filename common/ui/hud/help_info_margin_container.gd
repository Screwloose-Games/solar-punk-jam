extends MarginContainer

func _ready() -> void:
	if OS.has_feature("web"):
		show()
	else:
		hide()
