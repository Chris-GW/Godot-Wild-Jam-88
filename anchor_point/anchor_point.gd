class_name AnchorPoint 
extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var player : Player = body
		player.add_interactable(self)


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		var player : Player = body
		player.remove_interactable(self)


func do_interaction() -> void:
	var player : Player = get_tree().get_first_node_in_group("player") as Player
	var anchor_position := self.global_position
	player.grapple_control.attach_to_anchor_point(anchor_position)
