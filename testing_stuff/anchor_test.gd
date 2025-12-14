extends Area2D

var player : PlayerStateMachine

func _ready():
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body: Node2D):
	print("entering anchor range ", body)

	if body.is_in_group("player"):
		player = body.get_parent()
		player.add_interactable(self)

func do_interaction() -> void:
	player.attach_to_anchor_point(anchor_position)
