class_name GrappleControl
extends Node2D

@export var max_rope_length : float
@export var reel_in_speed : float
@export var let_out_speed : float

@export_category("Rope as Spring")
@export var stiffnes : float
@export var damping : float

@onready var player: Player = get_parent()
@onready var ray: RayCast2D = $RayCast2D
@onready var rope_line: Line2D = $RopeLine2D

var launched := false
var target := Vector2.ZERO
var rest_length := max_rope_length


func _ready() -> void:
	rope_line.hide()
	ray.target_position = Vector2.RIGHT * max_rope_length
	player.stamina_depleted.connect(self.retract)


func _process(delta: float) -> void:	
	if Input.is_action_just_pressed("grapple") and can_launch():
		launch()
	if Input.is_action_just_released("grapple"):
		retract()
	
	if launched and Input.is_action_pressed("reel_in_rope"):
		reel_in_rope(delta)
	if launched and Input.is_action_pressed("let_out_rope"):
		let_out_rope(delta)
	update_rope()


func _physics_process(delta: float) -> void:
	if launched:
		handle_grapple(delta)


func can_launch() -> bool:
	var stamina_percent := player.stamina / player.max_stamina
	return stamina_percent > 0.15

func launch() -> void:
	ray.look_at(get_global_mouse_position())
	ray.force_raycast_update()
	if ray.is_colliding():
		attach_to_anchor_point(ray.get_collision_point())


func retract() -> void:
	launched = false
	rope_line.hide()


func attach_to_anchor_point(anchor_position: Vector2) -> void:
	launched = true
	target = anchor_position
	rest_length = self.global_position.distance_to(anchor_position) 
	rest_length -= 20.0 
	rest_length = clampf(rest_length, 0.0, max_rope_length)
	update_rope()
	rope_line.show()


func handle_grapple(delta: float) -> void:
	var target_direction := player.global_position.direction_to(target)
	var target_distance := player.global_position.distance_to(target)
	var displacement := target_distance - rest_length
	
	if displacement <= 0.0001:
		return
	var spring_force_magnitude := stiffnes * displacement
	var spring_force := target_direction * spring_force_magnitude
	
	var velocity_dot := player.velocity.dot(target_direction)
	var damping_force := -damping * velocity_dot * target_direction
	var force := spring_force + damping_force
	player.velocity += force * delta


func update_rope() -> void:
	var rope_end_position := rope_line.to_local(target)
	rope_line.set_point_position(1, rope_end_position)


func reel_in_rope(delta: float) -> void:
	rest_length -= reel_in_speed * delta
	rest_length = maxf(rest_length, 0.0)
	#print(rest_length, " reel_in_rope")


func let_out_rope(delta: float) -> void:
	rest_length += let_out_speed * delta
	rest_length = minf(rest_length, max_rope_length)
	#print(rest_length, " let_out_rope")
