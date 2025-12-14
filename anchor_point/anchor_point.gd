class_name AnchorPoint 
extends Area2D

@onready var highlight: Node2D = $Highlight


func _ready() -> void:
	highlight.hide()


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.add_interactable(self)


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		body.remove_interactable(self)
		unselect_for_interaction()


func can_interact() -> bool:
	return true

func do_interaction() -> void:
	assert(can_interact(), "can_interact")
	var player : Player = get_tree().get_first_node_in_group("player") as Player
	var anchor_position := self.global_position
	player.grapple_control.attach_to_anchor_point(anchor_position)


func select_for_interaction() -> void:
	highlight.show()

func unselect_for_interaction() -> void:
	highlight.hide()
