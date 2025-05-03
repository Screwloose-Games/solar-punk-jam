extends StructureVisualInstance

func set_structure_status(status: StructureManager.STRUCTURE_STATUS):
	match status:
		StructureManager.STRUCTURE_STATUS.JUST_CREATED:
			$apple_tree.hide()
		_:
			$apple_tree.show()
