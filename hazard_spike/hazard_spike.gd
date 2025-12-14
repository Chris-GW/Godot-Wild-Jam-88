extends Area2D


@export var damage_amount : int


func _physics_process(_delta: float) -> void:
	for body in get_overlapping_bodies():
		if body.is_in_group("player"):
			damage_player(body)


func damage_player(player: Player) -> void:
	player.take_damage(damage_amount)
