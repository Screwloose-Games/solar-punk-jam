extends VBoxContainer

func _ready() -> void:
	for i in EnvironmentManager.characters:
		var b = Button.new()
		b.connect("pressed", StructureManager.register_character_structures.bind(i))
		b.text = "Unlock " + i
		add_child(b)
	for i in EnvironmentManager.resources:
		var b = Button.new()
		b.connect("pressed", EnvironmentManager.gain_resource.bind(i, 10))
		b.text = "Gain " + i
		add_child(b)
	
	var d = Button.new()
	d.connect("pressed", EnvironmentManager.deposit_resource.bind("Food", 1))
	d.text = "Donate 1 food"
	add_child(d)

	var b = Button.new()
	b.connect("pressed", EnvironmentManager.end_day)
	b.text = "Go to bed"
	add_child(b)
		
	
