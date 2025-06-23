class_name NpcController
extends Node

## Plays animations each night.

## Daily animations occur at night
@export var daily_animations: Dictionary[int, Array] = {}

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	EnvironmentManager.environment_model.day_updated.connect(_on_day_updated)

func _on_day_updated(day_num: int):
	var todays_animations = daily_animations.get(day_num)
	if todays_animations is Array:
		for animation in todays_animations:
			if animation is String and animation_player.has_animation(animation):
				animation_player.play(animation)
