extends PanelContainer

const QUEST_CONTAINER_RES = preload("res://common/ui/components/quest/quest_container.tscn")


func _ready() -> void:
	QuestManager.quests_changed.connect(update_quests)


func update_quests():
	var current_quests = $Content/Body.get_children()
	for i in QuestManager.quests.size():
		if i >= current_quests.size():
			var new_cont = QUEST_CONTAINER_RES.instantiate()
			$Content/Body.add_child(new_cont)
			new_cont.quest = QuestManager.quests[i]
		elif current_quests[i].quest == QuestManager.quests[i]:
			current_quests[i].update()
