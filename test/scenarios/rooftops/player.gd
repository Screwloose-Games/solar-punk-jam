extends Node3D
class_name CapybaraCharacter

func do_walk():
	$Model/AnimationPlayer.play("walking-stationary")

func do_idle():
	$Model/AnimationPlayer.play("idle")
