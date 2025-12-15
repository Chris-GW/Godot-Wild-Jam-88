extends Area2D


@export var damage_amount : int


func _physics_process(_delta: float) -> void:
	for body in get_overlapping_bodies():
		if body.is_in_group("player"):
			if body.get_parent() is PlayerStateMachine:
				damage_player(body.get_parent())
			else:
				# original player controller
				damage_player(body)
		

func damage_player(player) -> void:
	player.take_damage(damage_amount)
