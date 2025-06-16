extends StructureVisualInstance

func set_StructureStatus(status: StructureManager.StructureStatus):
	match status:
		StructureManager.StructureStatus.JUST_CREATED:
			$apple_tree.hide()
		_:
			$apple_tree.show()
