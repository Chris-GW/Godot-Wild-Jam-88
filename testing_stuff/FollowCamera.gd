extends Camera2D

@export var follow_target: Node2D
@export var offset_vector: Vector3 = Vector3(0, 3, -8)


var follow_speed_x: float = 10.0
var follow_speed_y: float = 10.0

var camera = self
var camera_speed := 400
var dragging := false
var last_mouse_pos := Vector2.ZERO

var default_zoom = Vector2.ONE

func _ready():
	set_zoom(default_zoom)


func _physics_process(delta: float) -> void:
	if follow_target == null:
		return

	var target_position =  Vector2(follow_target.global_position.x, follow_target.global_position.y)

	var current_x = global_position.x
	var current_y = global_position.y

	global_position = global_position.lerp(Vector2(target_position.x, current_y), follow_speed_x * delta)
	global_position = global_position.lerp(Vector2(current_x, target_position.y), follow_speed_y * delta)


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				#print("dragging")
				dragging = true
				last_mouse_pos = event.position
			else:
				#print("releasing")
				dragging = false

		elif event.button_index == 4 and event.pressed:  # Mouse wheel up
			var before = camera.get_global_mouse_position()
			camera.zoom *= 1.1  # Zoom out (bigger means further)
			var after = camera.get_global_mouse_position()
			camera.position += before - after
		elif event.button_index == 5 and event.pressed:  # Mouse wheel down
			var before = camera.get_global_mouse_position()
			camera.zoom *= 0.9  # Zoom in (smaller means closer)
			var after = camera.get_global_mouse_position()
			camera.position += before - after

	elif event is InputEventMouseMotion and dragging:
		var delta = event.position - last_mouse_pos
		#print("moving camera")
		position -= delta
		last_mouse_pos = event.position
