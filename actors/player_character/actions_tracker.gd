# Tracks actions currently available to the player
extends Node


var available_actions: Dictionary[InteractArea3D, InteractableArea3D]

@onready var interactions_v_box_container: VBoxContainer = %InteractionsVBoxContainer
@onready var interact_area_3d: InteractArea3D = %InteractArea3D
@onready var build_area_3d: InteractArea3D = %BuildArea3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interact_area_3d.selected_updated.connect(_on_interactable_selected_updated.bind(interact_area_3d))
	build_area_3d.selected_updated.connect(_on_interactable_selected_updated.bind(build_area_3d))

func _on_interactable_selected_updated(interactable: InteractableArea3D, interactor: InteractArea3D):
	available_actions[interactor] = interactable
	render_display()

func render_display():
	var actions = []
	for interactor in available_actions:
		if available_actions[interactor]:
			actions.append(available_actions[interactor].label_text)
	for child in interactions_v_box_container.get_children():
		interactions_v_box_container.remove_child(child)
	for action in actions:
		var label = Label.new()
		label.text = action
		interactions_v_box_container.add_child(label)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
