extends OptionButton

@onready var player: Player = owner

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	select(player.move_mode)
	item_selected.connect(_on_item_selected)
	pass # Replace with function body.


func _on_item_selected(index: int):
	#select(player.move_mode)
	player.move_mode = index




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
