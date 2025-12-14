extends CharacterBody2D

var input_direction: Vector2

var MAX_SPEED := 1000.0

var ACCEL      := 50.0      # how fast you reach target speed
var FRICTION := 40.0
#var AIR_FRICTION := 50
var GRAVITY    := 40.0

#var ACCEL_MODE := true
var ACCEL_MODE := false

signal hitting_wall(vec2, collider)

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

	#if not is_on_floor():
	#	apply_gravity(delta)

	# clamp max speed 
	if abs(velocity.x) > MAX_SPEED:
		velocity.x = sign(velocity.x) * MAX_SPEED

	floor_snap_length = 1.0
	#print("velocity: ", velocity)
	move_and_slide()

func apply_gravity(delta):
	velocity.y += GRAVITY
	
func _physics_process(delta: float) -> void:
	#draw_collision_normals()
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		handle_collision(collision)
		
func handle_collision(collision: KinematicCollision2D):
	var knockback_speed = 10.0
	var collider = collision.get_collider()
	var normal = collision.get_normal()
	#velocity += normal * knockback_speed

	if wall_collision(normal):
		#print("HITTING WALL")
		emit_signal("hitting_wall", normal, collision.get_collider())
		
func wall_collision(normal):
	return Vector2.UP.dot(normal) < 0.3
func floor_collision(normal):
	return Vector2.UP.dot(normal) > 0.7

		
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

func jump(y_speed):
	velocity.y = y_speed

	move_and_slide()
