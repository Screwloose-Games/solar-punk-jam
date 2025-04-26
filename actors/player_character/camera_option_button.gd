extends OptionButton

@onready var player: Player = owner

func _ready() -> void:
	select(player.camera_mode)
	item_selected.connect(_on_item_selected)

func _on_item_selected(index: int):
	player.camera_mode = index
