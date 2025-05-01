extends Area3D
class_name BuildableSurfaceArea3D

func activate():
	StructureManager.set_active_surface(get_parent())
	
