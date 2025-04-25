extends VBoxContainer

const OBJ_RESOURCE = preload("res://common/ui/components/quest/objective_container.tscn")

@onready var title = $Title
@onready var desc = $Description
@onready var obj_list = $Objectives

var quest : Quest : set = set_quest


func set_quest(val : Quest):
	quest = val
	title.text = quest.name
	desc.text = quest.description
	for objective in quest.objectives:
		var new_obj = OBJ_RESOURCE.instantiate()
		obj_list.add_child(new_obj)
		new_obj.objective = objective


func update():
	for objective in obj_list.get_children():
		objective.update()
	visible = !quest.is_complete
