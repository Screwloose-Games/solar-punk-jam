extends SoundPlayer3D

@export var player_node: Player

func _on_timer_timeout():
    if player_node.state == player_node.SelfState.WALK:
        play()