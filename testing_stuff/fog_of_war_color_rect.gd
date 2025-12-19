extends ColorRect

@onready var mat := material as ShaderMaterial

func _process(delta):
	mat.set_shader_parameter("fog_mask", FogOfWar.fog_texture)
