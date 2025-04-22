extends Node

@onready var face: MeshInstance3D = $"../example_person/Face"

enum FacialExpression {
	HAPPY,
	SAD
}

@export var happy_face: CompressedTexture2D:
	set(val):
		happy_face = val
		if override_material:
			override_material.albedo_texture = val
@export var doubt_face: CompressedTexture2D:
	set(val):
		doubt_face = val
		if override_material:
			override_material.albedo_texture = val

@export var expression: FacialExpression = FacialExpression.HAPPY:
	set(val):
		expression = val
		if not override_material:
			return
		if expression == FacialExpression.HAPPY:
			override_material.albedo_texture = happy_face
		else:
			override_material.albedo_texture = doubt_face
			



@onready var override_material: StandardMaterial3D = face.get_surface_override_material(0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
