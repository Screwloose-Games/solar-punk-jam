extends OptionButton

@onready var player: Player = owner

func _ready() -> void:
	select(player.move_mode)
	item_selected.connect(_on_item_selected)

func _on_item_selected(index: int):
	player.move_mode = index
