extends CharacterBody2D

var input_direction: Vector2

var MAX_SPEED := 1000.0

var ACCEL      := 50.0      # how fast you reach target speed
var FRICTION := 40.0
#var AIR_FRICTION := 50
var GRAVITY    := 40.0

#var ACCEL_MODE := true
var ACCEL_MODE := false

var last_velocity := Vector2.ZERO

signal hitting_wall(vec2, collider)
signal hitting_floor(vec2, collider)
signal taking_collision_damage(dmg: int)

func _ready():
	pass

func get_input() -> Vector2:
	return Input.get_vector("move_left","move_right","ui_up","ui_down")

func move(speed, delta):
	input_direction = get_input()

	var target_speed := 0.0
	if input_direction.x != 0.0:
		target_speed = input_direction.x * speed
		if ACCEL_MODE:
			velocity.x = move_toward(velocity.x, target_speed, ACCEL)
		else:
			velocity.x = target_speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, FRICTION)

	# clamp max speed 
	if abs(velocity.x) > MAX_SPEED:
		velocity.x = sign(velocity.x) * MAX_SPEED

	floor_snap_length = 8.0
	#print("velocity: ", velocity)
	move_and_slide()

func apply_gravity(delta):
	velocity.y += GRAVITY

func _process(delta):
	last_velocity = velocity
	
func _physics_process(delta: float) -> void:
	#last_velocity = velocity
	#draw_collision_normals()
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		handle_collision(collision)
		
func handle_collision(collision: KinematicCollision2D):
	var knockback_speed = 10.0
	var collider = collision.get_collider()
	var normal = collision.get_normal()
	#velocity += normal * knockback_speed

	var collision_damage = calculate_collision_damage(collision)
	if collision_damage > 0:
		taking_collision_damage.emit(collision_damage)
		
	if wall_collision(normal):
		#print("HITTING WALL")
		emit_signal("hitting_wall", normal, collision.get_collider())
	if floor_collision(normal):
		emit_signal("hitting_floor", normal, collision.get_collider())

var min_impact_speed = 1400.0
var max_impact_speed = 2200.0
var max_health = 100.0
var print_count = 0
func calculate_collision_damage(collision: KinematicCollision2D) -> int:
	# impact_speed is the speed at which the character hits the surface, 
	# measured along the direction pointing into the collider.
	var impact_speed = -last_velocity.dot(collision.get_normal())
	if impact_speed > 1400:
		print("IMPACT SPEED: ", impact_speed)
	
	if impact_speed < min_impact_speed:
		return 0
	
	# TODO: move this damage formula to the state machine:
	# the player controller is purely for collisions and movement
	# statemachine handles health and other stuff	
	var t := inverse_lerp(min_impact_speed, max_impact_speed, impact_speed)
	t = clampf(t, 0.0, 1.0)
	
	var damage = lerpf(5.0, max_health, t * t)
	print("impact_speed ", impact_speed, " calculate_collision_damage ", damage)
	return roundi(damage)

		
func wall_collision(normal):
	return Vector2.UP.dot(normal) < 0.3
func floor_collision(normal):
	return Vector2.UP.dot(normal) > 0.7

func jump(y_speed):
	velocity.y = y_speed

	move_and_slide()
		
# func draw_collision_normals() -> void:
# 	if debug_mesh == null:
# 		print("NO DEBUG MESH")
# 		return

# 	var count = get_slide_collision_count()
# 	if count == 0:
# 		return

# 	var im = debug_mesh.mesh as ImmediateMesh
# 	im.clear_surfaces()
# 	im.surface_begin(Mesh.PRIMITIVE_LINES)
# 	for i in range(get_slide_collision_count()):
# 		var collision = get_slide_collision(i)

# 		var p = collision.get_position()
# 		var n = collision.get_normal()

# 		var len = 2.0
# 		var start = p
# 		var end = p + n * len

# 		im.surface_set_color(Color.RED)
# 		im.surface_add_vertex(start)
# 		im.surface_add_vertex(end)

# 	im.surface_end()


# func _unhandled_input(event: InputEvent) -> void:
# 	if event.is_action_pressed("jump"):
# 		if is_on_floor():
# 			velocity.y = JUMP_SPEED
# 			#velocity.x *= 0.5
