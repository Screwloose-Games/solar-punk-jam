extends Node3D
class_name CapybaraCharacter

@export var character_walk_speed := 4.0
var character_walk_tween: Tween

func move_to_position(target: Vector3):
	if character_walk_tween:
		character_walk_tween.kill()
	character_walk_tween = create_tween()
	self.do_walk()
	var distance = self.position.distance_to(target)
	character_walk_tween.set_parallel(true)
	character_walk_tween.set_ease(Tween.EASE_IN_OUT)
	character_walk_tween.set_trans(Tween.TRANS_SINE)
	var player_rotation = self.rotation
	if target != self.position:
		self.look_at(target, Vector3.UP)
	character_walk_tween.tween_property(self, "rotation", self.rotation, 0.5).from(player_rotation)
	character_walk_tween.set_trans(Tween.TRANS_LINEAR)
	character_walk_tween.tween_property(self, "position", target, distance/character_walk_speed).set_delay(0.25)
	character_walk_tween.chain()
	character_walk_tween.tween_callback(self.do_idle)

func do_walk():
	$Model/AnimationPlayer.play("walking-stationary")

func do_idle():
	$Model/AnimationPlayer.play("idle")
