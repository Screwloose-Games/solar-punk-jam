## Tracks the quests in the game, their progress, and handles starting and completing quests.
extends Node

signal quest_started(quest: Quest)
signal quest_started_res(quest: Quest)
signal quests_changed
signal quest_completed(giver: String)
signal quest_cancelled(quest: Quest)

const FILE_PATH = "res://narrative/quests/%s.tres"
const TUTORIALS = ["a1d1_trin"]

var quests: Array[Quest] = []
var quest_markers: Array[QuestMarker3D] = []
var unlocked_quests: Array[Quest] = []


func _ready() -> void:
	Dialogic.VAR.variable_changed.connect(check_quests)
	# unlock_quest("a1d1_trin")
	GlobalSignalBus.world_unloaded.connect(_on_world_unloaded)

func _process(_delta: float) -> void:
	pass # Leave for breakpoints at any time in debugging class state

func cancel_quest(quest: Quest):
	quests.erase(quest)
	quest_cancelled.emit(quest)
	quests_changed.emit()


func reset_quests():
	for quest in quests:
		print(quest.resource_path)
		quest.reset()


func reset():
	#var all_quests: Array[Quest]
	reset_quests()
	quests.clear()
	quest_markers.clear()
	unlocked_quests.clear()
	Dialogic.VAR.clear_game_state()


func unlock_quest(quest_id: String):
	var full_file_path = FILE_PATH % ("qst_" + quest_id)
	var new_quest = load(full_file_path)
	if not new_quest:
		push_error("Could not unlock, locate quest with path:" + full_file_path)
		return
	unlock_quest_res(new_quest)


func unlock_quest_res(quest: Quest):
	if not quest.is_unlocked:
		quest.unlock()
	unlocked_quests.append(quest)
	quests_changed.emit()


func start_quest(file_name: String):
	var full_file_path = FILE_PATH % file_name
	var new_quest = load(full_file_path)
	if not new_quest:
		push_error("Could not start, locate quest with path:" + full_file_path)
		return
	start_quest_resource(new_quest)


func start_quest_resource(new_quest: Quest):
	if new_quest.state == Quest.QuestState.ACTIVE:
		return
	new_quest.state = Quest.QuestState.ACTIVE
	quests.append(new_quest)
	unlocked_quests.erase(new_quest)
	if !new_quest.quest_state_changed.is_connected(emit_signal.bind("quests_changed")):
		new_quest.quest_state_changed.connect(emit_signal.bind("quests_changed"))
	if !new_quest.quest_completed.is_connected(_on_quest_complete):
		new_quest.quest_completed.connect(_on_quest_complete)
	await new_quest.start_quest()
	check_quests()
	quest_started.emit(new_quest)
	quest_started_res.emit(new_quest)
	quests_changed.emit()
	print("Quest started: %s" % new_quest.name)


func check_quests(_changes: Dictionary = {}):
	for quest in quests:
		quest.check_progress()


func get_char_quest(character : DialogicCharacter) -> Quest:
	var unlocked_character_quests = unlocked_quests.filter(
		func (q: Quest): return (
			q.state == Quest.QuestState.AVAILABLE and q.giver == character
		)
	)
	if unlocked_character_quests.is_empty():
		return null
	else:
		return unlocked_character_quests[0]


func _on_world_unloaded():
	reset()


func _on_quest_complete(_giver : String):
	#Dialogic.VAR[giver + "_active"] = false
	quests_changed.emit()
	#quest_completed.emit(giver)


func get_quest_markers_by_id(id: String) -> Array[QuestMarker3D]:
	var markers: Array[QuestMarker3D]
	var nodes: Array[Node] = get_tree().get_nodes_in_group("QuestMarker")
	markers.append_array(nodes)
	markers = markers.filter(func(marker: QuestMarker3D): return marker.id == id)
	return markers
