class_name AnchorPoint 
extends Area2D

@onready var highlight: Node2D = $Highlight

var player
@onready var rope_line = $RopeLine2D
var target = Vector2.ZERO
@onready var rope_end: RigidBody2D = $RopeLine2D/RopeEndRigidBody

func _ready() -> void:
	highlight.hide()
	#rope_line.hide()
	rope_end.freeze = true
	some_target = null

func _physics_process(delta):
	if not is_instance_valid(rope_end):
		return
	if some_target == null:
		update_rope()
		return
	# 1. Compute spring force
	var current_pos: Vector2 = rope_end.global_position
	var to_target: Vector2 = some_target - current_pos
	var distance: float = to_target.length()
	if distance > 0.0001:
		var direction: Vector2 = to_target / distance

		# Displacement is "how far from rest"
		var displacement: float = distance

		# Hooke’s law: F = k * x
		var spring_force: Vector2 = direction * (stiffness * displacement)

		# Damping: oppose motion along the spring direction
		var velocity_along: float = rope_end.linear_velocity.dot(direction)
		var damping_force: Vector2 = -damping * velocity_along * direction

		var total_force: Vector2 = spring_force + damping_force

		# 2. Apply to the rigidbody as a continuous force
		rope_end.apply_central_force(total_force)

	update_rope()
	
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
		# player.grapple_control.attach_to_anchor_point(anchor_position)
		player.grapple_control.attach_to_anchor_point_with_rope(self)
		player.is_interacting.emit(self)

var stiffness = 120.0
var damping = 20.0
var some_force # what is this supposed to be?
func spring_force(delta) -> Vector2:
	var target
	var target_direction
	var target_distance
	var displacement
	if displacement <= 0.0001:
		return Vector2.ZERO
	var spring_force_mag = stiffness * displacement
	var spring_force = target_direction * spring_force_mag
	var some_velocity
	var velocity_dot = some_velocity.dot(target_direction)
	var damping_force = -damping * velocity_dot * target_direction
	var force = spring_force + damping_force
	some_force += force * delta
	return some_force

var some_target # what is this supposed to be?
var some_position # what is this supposed to be?
func update_rope() -> void:
	var start = rope_line.to_local(global_position)
	rope_line.set_point_position(0, start)
	var end = rope_line.to_local(rope_end.global_position)
	rope_line.set_point_position(1,end)

func detach(detached_pos):
	print("DETACH:", detached_pos, " anchor:", global_position)
	#some_target = rope_end.global_position
	#some_target = detached_pos
	rope_end.global_position = detached_pos
	rope_end.linear_velocity = Vector2.ZERO
	var rope_length = detached_pos.distance_to(global_position)
	some_target = global_position + Vector2.DOWN * rope_length
	#some_target = detached_pos
	rope_end.freeze = false

func select_for_interaction() -> void:
	highlight.show()

func unselect_for_interaction() -> void:
	highlight.hide()
