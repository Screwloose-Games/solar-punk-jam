extends PanelContainer

const QUEST_CONTAINER_RES = preload("res://common/ui/components/quest/quest_container.tscn")
@onready var body: VBoxContainer = %Body


func _ready() -> void:
	QuestManager.quests_changed.connect(update_quests)
	hide()


func clear_quest_nodes():
	for node in body.get_children():
		body.remove_child(node)


func update_quests():
	clear_quest_nodes()
	var active_quests = QuestManager.quests.filter(func(quest: Quest): return quest.state == quest.QuestState.ACTIVE)
	for i in active_quests.size():
		var new_cont: QuestContainer = QUEST_CONTAINER_RES.instantiate()
		new_cont.quest = active_quests[i]
		body.add_child(new_cont)
	visible = !active_quests.is_empty()
