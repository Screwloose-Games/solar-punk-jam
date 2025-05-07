extends Area3D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: PhysicsBody3D):
	GlobalSignalBus.player_entered_home.emit()
	print("Player entered")
