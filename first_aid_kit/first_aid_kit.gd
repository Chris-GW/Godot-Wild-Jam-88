class_name FirstAidKit
extends Area2D


@export var heal_amount : int


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		try_pickup(body)

	elif body.is_in_group("player"):
		#print("entering firstaidkit")
		# TODO: the body is the playercontroller, the parent is statemachine
		var player = body.get_parent()
		if player is PlayerStateMachine: try_pickup(player)

func try_pickup(player) -> void:
	if player.health < player.max_health:
		player.change_health(+heal_amount)
		queue_free()
