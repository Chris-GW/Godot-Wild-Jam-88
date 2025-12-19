class_name FallingRock
extends RigidBody2D

@export var damage: int


func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	for body in get_colliding_bodies():
		if body.get_parent() is PlayerStateMachine:
			damage_player(body.get_parent())
		elif body is Player:
			# original player controller
			damage_player(body)


func damage_player(body):
	body.take_damage(damage)
	self.queue_free()
