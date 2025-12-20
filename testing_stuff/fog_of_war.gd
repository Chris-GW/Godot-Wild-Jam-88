extends Node

var fog_image: Image
var fog_texture: ImageTexture

@export var fog_size: Vector2i = Vector2i(1024, 1024)
@export var world_size: Vector2 = Vector2(4096, 4096)  # size of your level in world units

func _ready():
	fog_image = Image.create(fog_size.x, fog_size.y, false, Image.FORMAT_RF)
	fog_image.fill(Color.BLACK)
	fog_texture = ImageTexture.create_from_image(fog_image)

func reset_fog():
	fog_image = Image.create(fog_size.x, fog_size.y, false, Image.FORMAT_RF)
	fog_image.fill(Color.BLACK)
	fog_texture = ImageTexture.create_from_image(fog_image)
	
func clear_fog_at(world_pos: Vector2, radius: float) -> void:
	# world (0..world_size) -> 0..1 UV
	var uv := Vector2(world_pos.x / world_size.x, world_pos.y / world_size.y)
	uv = uv.clamp(Vector2.ZERO, Vector2.ONE)

	# 0..1 -> fog texture pixels
	var center := Vector2(uv.x * fog_size.x, uv.y * fog_size.y)
	var r2 := radius * radius

	for y in range(center.y - int(radius), center.y + int(radius)):
		if y < 0 or y >= fog_size.y: continue
		for x in range(center.x - int(radius), center.x + int(radius)):
			if x < 0 or x >= fog_size.x: continue
			var d2 = (Vector2(x, y) - center).length_squared()
			if d2 <= r2:
				fog_image.set_pixel(x, y, Color(1, 1, 1))

	fog_texture.update(fog_image)
