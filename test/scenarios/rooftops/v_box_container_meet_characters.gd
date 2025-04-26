extends VBoxContainer
const characters_to_meet = ["Farmer", "Electrician", "Permaculturist", "Someone else"]
func _ready() -> void:
	for i in characters_to_meet:
		var b = Button.new()
		b.connect("pressed", StructureManager.register_character_structures.bind(i))
		b.text = "Meet with " + i
		add_child(b)
