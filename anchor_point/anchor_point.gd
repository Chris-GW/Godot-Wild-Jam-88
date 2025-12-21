class_name AnchorPoint 
extends Area2D

@onready var highlight: Node2D = $Highlight

var player
@onready var rope_line = $RopeLine2D
var target = Vector2.ZERO
@onready var rope_end: RigidBody2D = $RopeLine2D/RopeEndRigidBody
@onready var rope_end_area2d: RopeEndArea2D = $RopeLine2D/RopeEndRigidBody/RopeEndArea2D
var max_rope_length #= 400.0
var rest_length = max_rope_length

var stiffness = 120.0
var damping = 20.0

var is_attached := false

func _ready() -> void:
	rope_end_area2d.interacting_with_rope_end.connect(_on_interacting_with_rope_end)
	highlight.hide()
	#rope_line.hide()
	rope_end.freeze = true
	some_target = null

func _physics_process(delta):
	if not is_instance_valid(rope_end):
		return

	if is_attached and player:
		rope_end.global_position = player.player_controller.global_position
	#otherwise simulate rope_end under gravity
	#spring force
	elif not is_attached and some_target:
		var idle_target = some_target # some_target set in detach()
		var current_rope_end_pos: Vector2 = rope_end.global_position
		var to_target: Vector2 = idle_target - current_rope_end_pos
		var distance: float = to_target.length()
		if distance > 0.0001:
			var total_force = spring_calculation(to_target, distance)
			# 2. Apply to the rigidbody as a continuous force
			rope_end.apply_central_force(total_force)

		var offset = rope_end.global_position - global_position
		var dist = offset.length()
		if dist > max_rope_length:
			offset = offset.normalized() * max_rope_length
			rope_end.global_position = global_position + offset
			
	update_rope()
	
var some_target # what is this supposed to be?
func update_rope() -> void:
	var start = rope_line.to_local(global_position)
	rope_line.set_point_position(0, start)
	var end = rope_line.to_local(rope_end.global_position)
	rope_line.set_point_position(1,end)

func spring_calculation(to_target_vector: Vector2, distance: float):
	var direction = to_target_vector/distance
	var displacement = distance # how far from rest position
	
	var spring_force = direction * (stiffness * displacement)
	#damping
	var velocity_along = rope_end.linear_velocity.dot(direction)
	var damping_force = -damping * velocity_along * direction
	var total_force = spring_force + damping_force
	return total_force

	
func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.add_interactable(self)

	# my testing player controller is in the player group
	elif body.is_in_group("player"):
		print("entering anchor")
		player = body.get_parent() # player_state_machine
		select_for_interaction()
		player.add_interactable(self)
		max_rope_length = player.grappling_state.max_rope_length
		

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		body.remove_interactable(self)
		unselect_for_interaction()
		
	# my testing player controller is in the player group
	elif body.is_in_group("player"):
		print("exiting anchor")
		player = body.get_parent() # player_state_machine
		unselect_for_interaction() 
		player.remove_interactable(self)
		
func can_interact() -> bool:
	return true

func do_interaction() -> void:
	assert(can_interact(), "can_interact")
	#var anchor_position := self.global_position
	player.is_interacting.emit(self)

# var rope_base_len = 64.0
# func attach_at_anchor(anchor: AnchorPoint, player):
# 	is_attached = true
# 	rope_end.freeze = true
# 	rest_length = player.player_controller.global_position.distance_to(global_position)
# 	rest_length += rope_base_len
# 	rest_length = clampf(rest_length, 0.0, max_rope_length)
# 	#update_rope_in_anchorpoint(anchor)
# 	some_target = player.player_controller.global_position
# 	update_rope()
# 	rope_line.show()

func detach(detached_pos):
	is_attached = false
	#print("DETACH:", detached_pos, " anchor:", global_position)
	#some_target = rope_end.global_position
	#some_target = detached_pos
	rope_end.global_position = detached_pos
	rope_end.linear_velocity = Vector2.ZERO
	#var rope_length = detached_pos.distance_to(global_position)
	some_target = global_position + Vector2.DOWN * max_rope_length
	#some_target = detached_pos
	rope_end.freeze = false
	rope_end_area2d._can_interact = true

func select_for_interaction() -> void:
	highlight.show()

func unselect_for_interaction() -> void:
	highlight.hide()

func _on_interacting_with_rope_end():
	player.is_interacting.emit(self)
	
func _on_rope_end_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.get_parent() is PlayerStateMachine:
			var player = body.get_parent()
			print("WE GOT PLAYER IN ROPE END AREA 2D")
			rope_end_area2d.select_for_interaction()
			player.add_interactable(rope_end_area2d)

func _on_rope_end_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.get_parent() is PlayerStateMachine:
			var player = body.get_parent()
			player.remove_interactable(rope_end_area2d)
			rope_end_area2d.unselect_for_interaction()

			
