extends Area2D


@export var damage_amount : int


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var player: Player = body
		player.take_damage(damage_amount)
