class_name FirstAidKit
extends Area2D


@export var heal_amount : int


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		try_pickup(body)


func try_pickup(player: Player) -> void:
	if player.health < player.max_health:
		player.change_health(+heal_amount)
		queue_free()
