extends Path2D

@export var record_target: RigidBody2D
@export var record_length: float
@export var save_path: String

var fall_positions := Curve2D.new()


func _ready() -> void:
	fall_positions.clear_points()
	fall_positions.add_point(record_target.global_position)


func _physics_process(delta: float) -> void:
	record_length -= delta
	
	if is_instance_valid(record_target) and record_length > 0.0:
		fall_positions.add_point(record_target.global_position)
	else:
		ResourceSaver.save(fall_positions, save_path)
		queue_free()
