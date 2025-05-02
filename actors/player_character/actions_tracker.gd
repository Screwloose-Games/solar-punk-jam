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
	var action_inputs = []
	for interactor in available_actions:
		if available_actions[interactor]:
			actions.append(available_actions[interactor].label_text)
			action_inputs.append(interactor.interact_action)
	for child in interactions_v_box_container.get_children():
		interactions_v_box_container.remove_child(child)
	for index in actions.size():
		var action = actions[index]
		var label = Label.new()
		label.text = action
		var hbox = HBoxContainer.new()
		var controller_icon = ControllerIconTexture.new()
		controller_icon.path = action_inputs[index]
		var texture_rect = TextureRect.new()
		texture_rect.texture = controller_icon
		texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		texture_rect.custom_minimum_size = Vector2(50, 50)
		hbox.add_child(texture_rect)
		hbox.add_child(label)
		interactions_v_box_container.add_child(hbox)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
