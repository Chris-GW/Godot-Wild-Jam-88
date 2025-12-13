class_name Mover extends Node2D

var MIN_SPEED := 0.0
var MAX_SPEED := 1000.0

var velocity := Vector2(0.0,0.0)
var acceleration := Vector2(0.0, 0.0)
var speed_change := 2.0

var angle = 0.0
var angle_velocity = 0.0
var angle_acceleration = 0.001

var radius = 10.0
var color = Color(1,1,1,1)

var noise := FastNoiseLite.new()

var mass: float = 1000.0

var edges := Vector2.ZERO

var slowing = false

func _ready() -> void:
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = 0.05

	radius = get_radius(mass)

var timer := 0.0
var timelimit = 0.25

func _process(delta: float) -> void:
	if contact_floor(edges):
		var c = 0.1
		var friction = velocity * -1
		friction = friction.normalized() * c
		apply_force(friction)

	velocity += acceleration
	velocity = velocity.limit_length(MAX_SPEED)
	position += velocity

	#angle_velocity += angle_acceleration
	#angle += angle_velocity*delta
	#angle = clamp(angle, 0.0, 0.5)
	#rotate(angle)
	
	timer+=delta
	if timer >= timelimit:
		timer = 0.0

	# NOTE: choose either to bounce_edges OR cycle_edges (or neither)
	inelastic_bounce_edges(edges)

	queue_redraw()

	# clear acceleration afer it's been applied
	acceleration *= 0

func gravity():
	var gravity = Vector2(0.0,0.6)
	var g = gravity * mass
	apply_force(g)
	
var wind_step = 0.0
func wind_force(delta):
	wind_step += delta
	var noise_val = noise.get_noise_1d(wind_step)
	apply_force(Vector2(noise_val,noise_val))
	
func apply_force(force):
	force /= mass
	acceleration += force

func contact_floor(edges):
	return global_position.y > edges.y - radius - 1
	
# func mouse_acceleration():
# 	if camera:
# 		var mouse_pos = camera.get_global_mouse_position()
# 		var dir = position.direction_to(mouse_pos)
				
# 		apply_force(dir*100.0)
		
var step = 0.0
func noise_acceleration(delta):
	step += delta
	var noise_val = noise.get_noise_2d(step, step)
	acceleration = Vector2(noise_val*randf_range(-1.0,1.0)*2.0, noise_val*randf_range(-1.0,1.0)*2.0)
		
func random_acceleration():
	var angle = randf() * TAU
	var angle_norm = Vector2(cos(angle), sin(angle))
	acceleration = angle_norm * 2.0	
		
func _input(event):
	#print(event.as_text())

	if event.is_action_pressed("debug_faster"):
		velocity *= 2.0
		print(velocity)
		
	if event.is_action_pressed("debug_slower"):
		velocity *= 0.5
		print(velocity)
	
	# if event.is_action_pressed("wind"):
	# 	var wind = Vector2(100.0, 0.0)
	# 	apply_force(wind)
		
var dead = false
func inelastic_bounce_edges(edges: Vector2):
	var bounce = -0.2
	if position.x-radius < 0:
		position.x = 0 + radius
		velocity.x *= bounce
	if position.x+radius > edges.x:
		position.x = edges.x-radius
		velocity.x *= bounce
	if position.y-radius < 0:
		velocity.y *= bounce
		position.y = 0 + radius
	if position.y+radius > edges.y:
		velocity.y *= bounce
		position.y = edges.y - radius
		if not dead:
			print("VELOCITY AT IMPACT: ", velocity)
			dead = true

func inelastic_drag_edges(edges: Vector2) -> Vector2:
	var vec := Vector2.ZERO
	if position.x-radius < 0:
		vec.x = -1
		
	if position.x+radius > edges.x:
		vec.x = -1
		
	if position.y-radius < 0:
		vec.y = -1

	if position.y+radius > edges.y:
		vec.y = -1

	return vec
	

func get_radius(mass: float) -> float:
	var min_mass := 1.0
	var max_mass := 100.0
	var min_radius := 8.0
	var max_radius := 64.0

	var m_clamped = clamp(mass, min_mass, max_mass)
	var t = (log(m_clamped) - log(min_mass)) / (log(max_mass) - log(min_mass))
	return lerp(min_radius, max_radius, t)



var line_len = 10
func _draw():
	draw_circle(Vector2.ZERO, radius, color) # NOTE: REMEBER THIS IS --LOCAL-- so i need to draw at 0,0
	
	var a = velocity.angle()
	var dir = Vector2.RIGHT.rotated(a) # unit vector in heading dir
	var end = dir * line_len
	draw_line(Vector2.ZERO, end, Color.RED, 1.0)
	
