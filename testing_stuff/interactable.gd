class_name Interactable extends Area2D

@onready var highlight: Node2D = $Highlight
@onready var my_tween_label = $MyTweenLabel

#signal interacting_with(i: Interactable)

var _can_interact = true
var player : PlayerStateMachine

func _init():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _ready():
	highlight.hide()

func do_interaction(): 
	player.is_interacting.emit(self)

func can_interact():
	return _can_interact

func select_for_interaction() -> void:
	highlight.show()

func unselect_for_interaction() -> void:
	highlight.hide()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.get_parent() is PlayerStateMachine:
			#print("entering interactable")
			player = body.get_parent() # player_state_machine
			select_for_interaction()
			player.add_interactable(self)
		
func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.get_parent() is PlayerStateMachine:
			#print("exiting interactable")
			player = body.get_parent() # player_state_machine
			unselect_for_interaction() 
			player.remove_interactable(self)
