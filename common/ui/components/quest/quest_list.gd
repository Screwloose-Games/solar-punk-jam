extends PanelContainer

const QUEST_CONTAINER_RES = preload("res://common/ui/components/quest/quest_container.tscn")


func _ready() -> void:
	QuestManager.quests_changed.connect(update_quests)
	hide()


func update_quests():
	var current_quests = $Content/Body.get_children()
	var vis_check = false
	for i in QuestManager.quests.size():
		if i >= current_quests.size():
			var new_cont = QUEST_CONTAINER_RES.instantiate()
			$Content/Body.add_child(new_cont)
			new_cont.quest = QuestManager.quests[i]
			vis_check = true
		elif current_quests[i].quest == QuestManager.quests[i]:
			current_quests[i].update()
			vis_check = !QuestManager.quests[i].is_complete
	visible = vis_check
