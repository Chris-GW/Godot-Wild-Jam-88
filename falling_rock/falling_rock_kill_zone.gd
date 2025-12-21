extends Area2D


func _ready() -> void:
	assert(get_collision_mask_value(8), "mask falling rocks")
	assert(monitoring, "monitoring falling rocks")
	self.body_entered.connect(_on_body_entered)


func _on_body_entered(body) -> void:
	if body is FallingRock:
		body.queue_free()
