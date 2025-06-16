extends StructureVisualInstance

func set_StructureStatus(status: StructureManager.StructureStatus):
	match status:
		StructureManager.StructureStatus.READY:
			$Fruit.show()
		_:
			$Fruit.hide()
