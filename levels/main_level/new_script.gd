extends Node

const QST_BUILD_1 = preload("res://narrative/quests/qst_build1.tres")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func start_scene():
	await QuestManager.quest_started("quest_id")
	await QST_BUILD_1.started()
	Quest
	
	Dialogic.start("planter_tut")
	await GlobalSignalBus.structure_placed(Structure.type.VERTICAL_PLANTER)
	Dialogic.start("planter_tut", "after_planter")
	await GlobalSignalBus.structure_interacted(Structure.type.VERTICAL_PLANTER)
	Dialogic.start("planter_tut", "player_interacted_with_compost_bin")
