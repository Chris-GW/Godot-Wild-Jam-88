extends ColorRect

@onready var fog_of_war = get_parent()
@onready var mat := material as ShaderMaterial

func _process(delta):
	mat.set_shader_parameter("fog_mask", fog_of_war.fog_texture)
