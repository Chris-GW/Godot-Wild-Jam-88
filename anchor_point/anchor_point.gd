class_name AnchorPoint 
extends Area2D

@onready var highlight: Node2D = $Highlight

var player

func _ready() -> void:
	highlight.hide()


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.add_interactable(self)

	# my testing player controller is in the player group
	elif body.is_in_group("player"):
		print("entering anchor")
		# TODO: the body is the playercontroller, the parent is statemachine
		player = body.get_parent()
		player.add_interactable(self)

		
func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		body.remove_interactable(self)
		unselect_for_interaction()
		
	# my testing player controller is in the player group
	elif body.is_in_group("player"):
		print("exiting anchor")
		# TODO: the body is the playercontroller, the parent is statemachine
		player = body.get_parent()
		unselect_for_interaction()
		player.remove_interactable(self)
		

func can_interact() -> bool:
	return true

func do_interaction() -> void:
	assert(can_interact(), "can_interact")
	var anchor_position := self.global_position
	if player:
		# TODO: is this part of moving to the state machine?
		# call attach_to_anchor point inside GrapplingState?
		player.grapple_control.attach_to_anchor_point(anchor_position)
		#TODO: changing to emitting signals from interactable objects
		player.is_interacting.emit(self)


func select_for_interaction() -> void:
	highlight.show()

func unselect_for_interaction() -> void:
	highlight.hide()
