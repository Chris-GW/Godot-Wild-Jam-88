class_name RepairTarget
extends Area2D

signal repaired(target: RepairTarget)

@export var is_repaired := false
## if this repair target must be repaired for level completion
@export var required_repair := true 

@onready var highlight: Node2D = $Highlight
@onready var sprite_2: Sprite2D = $Sprite2D2

var player

func _ready() -> void:
	highlight.hide()


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.add_interactable(self)

	# my player_test controller is in the player group
	elif body.is_in_group("player"):
		print("entering repair_target")
		# TODO: the body is the playercontroller, the parent is statemachine. I want the statemachine.
		player = body.get_parent()
		player.add_interactable(self)

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		body.remove_interactable(self)
		unselect_for_interaction()

	# my player_test controller is in the player group
	elif body.is_in_group("player"):
		print("entering repair_target")
		# TODO: the body is the playercontroller, the parent is statemachine. I want the statemachine.
		player = body.get_parent()
		player.remove_interactable(self)
		unselect_for_interaction()

func can_interact() -> bool:
	return not is_repaired

func do_interaction() -> void:
	if not can_interact():
		return
	if player:
		player.is_interacting.emit(self)
	is_repaired = true
	monitoring = false
	monitorable = false
	sprite_2.self_modulate = Color.GREEN
	var tween := create_tween()
	tween.set_loops()
	tween.tween_property(sprite_2, "rotation", deg_to_rad(360.0), 5.0)
	repaired.emit(self)


func select_for_interaction() -> void:
	highlight.show()

func unselect_for_interaction() -> void:
	highlight.hide()
