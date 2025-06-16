extends VBoxContainer

const OBJ_RESOURCE = preload("res://common/ui/components/quest/step_container.tscn")

var quest: Quest:
	set = set_quest

@onready var title = $Title
@onready var desc = $Description
@onready var obj_list = $Objectives

func set_quest(val: Quest):
	quest = val
	title.text = quest.name
	desc.text = quest.description
	for step in quest.steps:
		var new_obj = OBJ_RESOURCE.instantiate()
		obj_list.add_child(new_obj)
		new_obj.step = step


func update():
	for step in obj_list.get_children():
		step.update()
	visible = !quest.is_complete
