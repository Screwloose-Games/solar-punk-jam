extends StructureVisualInstance

func set_structure_status(status: StructureManager.STRUCTURE_STATUS):
	match status:
		StructureManager.STRUCTURE_STATUS.READY:
			$Fruit.show()
		_:
			$Fruit.hide()
