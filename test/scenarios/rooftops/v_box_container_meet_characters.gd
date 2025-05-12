extends VBoxContainer

func _ready() -> void:
	# TODO: clean up. Check if theres lingering UI.
	# if false: 
		#for i in ResourcesManager.characters:
			#var b = Button.new()
			#b.connect("pressed", StructureManager.register_character_structures.bind(i))
			#b.text = "Unlock " + i
			#add_child(b)
	if true:
		for i in ResourcesManager.resources:
			var b = Button.new()
			b.connect("pressed", ResourcesManager.gain_resource.bind(i, 10))
			b.text = "Gain " + i
			add_child(b)
	if false:
		var d = Button.new()
		d.connect("pressed", ResourcesManager.deposit_resource.bind("Food", 1))
		d.text = "Donate 1 food"
		add_child(d)

		var b = Button.new()
		b.connect("pressed", EnvironmentManager.end_day)
		b.text = "Go to bed"
		add_child(b)
	if true:
		var b = Button.new()
		b.connect("pressed", StructureManager.register_all_structures)
		b.text = "Unlock everything"
		add_child(b)
