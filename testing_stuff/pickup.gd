class_name Pickup 
extends Area2D

@export var text: String

@onready var my_tween_label = $MyTweenLabel


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		#print("entering pickup")
		# TODO: the body is the playercontroller, the parent is statemachine
		var player = body.get_parent()
		if player is PlayerStateMachine: 
			try_pickup(player)

func try_pickup(player) -> void:
	my_tween_label.move_above_player(player.player_controller)
	my_tween_label.show_floating(text)
