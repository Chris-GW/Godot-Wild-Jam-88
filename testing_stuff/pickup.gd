class_name Pickup 
extends Area2D

@export var text: String
@export var icon_texture: Texture2D

@onready var sprite = $Sprite2D
@onready var vanish_timer = $VanishTimer
@export var vanish_on_pickup: bool = false

var player: PlayerStateMachine

func _ready():
	vanish_timer.timeout.connect(_vanish_timer_timeout)
	
	if icon_texture:
		sprite.texture = icon_texture

@onready var my_tween_label = $MyTweenLabel


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		#print("entering pickup")
		# TODO: the body is the playercontroller, the parent is statemachine
		player = body.get_parent()
		if player is PlayerStateMachine: try_pickup(player)

		if vanish_on_pickup:
			vanish_timer.start()

func _vanish_timer_timeout():
	player.change_rope_length(600)
	queue_free()

			
func _process(delta):
	pass
			

func try_pickup(player) -> void:
	my_tween_label.move_above_player(player.player_controller)
	my_tween_label.show_floating(text)
