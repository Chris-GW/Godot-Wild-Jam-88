class_name GrappleControl
extends Node2D

@export var max_rope_length : float
@export var reel_in_speed : float
@export var let_out_speed : float

@export_category("Rope as Spring")
@export var stiffnes : float
@export var damping : float

@onready var player = get_parent()
@onready var ray: RayCast2D = $RayCast2D
@onready var rope_line: Line2D

var launched := false
var target := Vector2.ZERO
var rest_length := max_rope_length


func _ready() -> void:
	#ray.target_position = Vector2.RIGHT * max_rope_length
	player.stamina_depleted.connect(self.retract)

	#rope_line = Global.find_node_if_type(self, func(n): return n is Line2D)
	rope_line = $RopeLine2D
	if rope_line == null:
		print("no rope line")
		return
	else:
		print("rope line from grapple control: ", rope_line)
		
	# initialize the minimum 2 points needed for Line2D
	if rope_line.get_point_count() < 2:
		rope_line.clear_points()
		rope_line.add_point(Vector2.ZERO)
		rope_line.add_point(Vector2.ZERO)

	rope_line.hide()
	


func _process(delta: float) -> void:	
	# if Input.is_action_just_pressed("grapple") and can_launch():
	# 	launch()
	# if Input.is_action_just_released("grapple"):
	# 	retract()

	# TODO: move to the Grappling class within PlayerStateMachine to control player behavior
	#if launched and Input.is_action_pressed("reel_in_rope"):
	#	reel_in_rope(delta)
	#if launched and Input.is_action_pressed("let_out_rope"):
	#	let_out_rope(delta)

	# TODO: reenable when I know i'm getting my reference to rope Line2D
	#update_rope()
	pass


# Moving to playerstatemachine Grappling state 
func _physics_process(delta: float) -> void:
	# if launched:
	# 	#print("TARGET:", target)
	# 	handle_grapple(delta)
	pass


func can_launch() -> bool:
	var stamina_percent = player.stamina / player.max_stamina
	return stamina_percent > 0.15

func launch() -> void:
	# ray.look_at(get_global_mouse_position())
	# ray.force_raycast_update()
	# if ray.is_colliding():
	# 	attach_to_anchor_point(ray.get_collision_point())
	pass

func retract() -> void:
	launched = false
	rope_line.hide()

func attach_to_anchor_point(anchor_position: Vector2) -> void:
	launched = true
	target = anchor_position
	rest_length = player.player_controller.global_position.distance_to(anchor_position) 
	rest_length += 64.0 
	rest_length = clampf(rest_length, 0.0, max_rope_length)
	update_rope()
	rope_line.show()
	print("attaching to target: ", target)

# WIP: ben
var rope_base_len = 64.0
func attach_to_anchor_point_with_rope(anchor: AnchorPoint):
	var rope = anchor.rope_line
	rest_length = player.player_controller.global_position.distance_to(anchor.global_position)
	rest_length += rope_base_len
	rest_length = clampf(rest_length, 0.0, max_rope_length)
	update_rope_in_anchorpoint(anchor)
	rope.show()

# WIP: ben
func detach_from_anchor_point_with_rope(anchor: AnchorPoint, detached_pos):
	anchor.detach(detached_pos)

	
# TODO: how to move this to my statemachine? that's where i'm deciding movement by current state
# this logic is fine here, but call handle_grapple from statemachine
func handle_grapple(delta: float) -> void:
	var target = player.current_state.current_anchor.global_position
	var target_direction = player.player_controller.global_position.direction_to(target)
	var target_distance = player.player_controller.global_position.distance_to(target)
	var displacement = target_distance - rest_length
	
	if displacement <= 0.0001:
		return
	var spring_force_magnitude = stiffnes * displacement
	var spring_force = target_direction * spring_force_magnitude
	
	var velocity_dot = player.player_controller.velocity.dot(target_direction)
	var damping_force = -damping * velocity_dot * target_direction
	var force = spring_force + damping_force
	player.player_controller.velocity += force * delta
	

func update_rope() -> void:
	#TODO: fix so that i make check for the type of player (statemachine vs player)
	# TODO: for going up grapple,
	# need to keep updating rope, and use an end_poition node
	# on the rope, with some physics?
	var start = rope_line.to_local(player.player_controller.global_position)
	rope_line.set_point_position(0,start)
	var end := rope_line.to_local(target)
	rope_line.set_point_position(1, end)

# WIP: ben
func update_rope_in_anchorpoint(anchor: AnchorPoint) -> void:
	var rope = anchor.rope_line
	var start = rope. to_local(player.player_controller.global_position)
	rope.set_point_position(0,start)
	# is this right? the target is just the anchor position?
	var end = rope.to_local(anchor.global_position)
	rope.set_point_position(1,end)
	
func reel_in_rope(delta: float) -> void:
	rest_length -= reel_in_speed * delta
	rest_length = maxf(rest_length, 0.0)
	#print(rest_length, " reel_in_rope")


func let_out_rope(delta: float) -> void:
	rest_length += let_out_speed * delta
	rest_length = minf(rest_length, max_rope_length)
	#print(rest_length, " let_out_rope")
