@tool
extends Control

@onready var quest_designer_canvas: QuestDesignerCanvas = %QuestDesignerCanvas


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#if Engine.is_editor_hint():
	quest_designer_canvas.connection_request.connect(_on_connection_request)
	quest_designer_canvas.disconnection_request.connect(_on_disconnection_request)


func _on_connection_request(
	from_node: StringName, from_port: int, to_node: StringName, to_port: int
) -> void:
	# Get the actual nodes
	var from: QuestEditUi = quest_designer_canvas.get_node(NodePath(from_node))
	var to: QuestEditUi = quest_designer_canvas.get_node(NodePath(to_node))

	# Let the nodes handle the connection
	from._on_connection_request(from, from_port, to, to_port)

	# Create the connection in the graph
	quest_designer_canvas.connect_node(from_node, from_port, to_node, to_port)


func _on_disconnection_request(
	from_node: StringName, from_port: int, to_node: StringName, to_port: int
) -> void:
	# Get the actual nodes
	var from: QuestEditUi = quest_designer_canvas.get_node(NodePath(from_node))
	var to: QuestEditUi = quest_designer_canvas.get_node(NodePath(to_node))

	# Clear the next_quest reference
	if from.quest:
		from.quest.next_quest = null

	# Remove the connection from the graph
	quest_designer_canvas.disconnect_node(from_node, from_port, to_node, to_port)
