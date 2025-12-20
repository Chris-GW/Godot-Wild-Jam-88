class_name FallingRockSpawner
extends Path2D

signal rock_spawned(rock: FallingRock)

const FALLING_ROCK = preload("uid://cwdnaouxw5ko5")

# wait time in seconds for each spawn (looping) eg [3.0, 2.5] waits 3.0 sec for spawn rock
@export var spawn_times: Array[float] = []
@export var inital_velocity := Vector2.DOWN
@export var record_fall_path := false

@onready var spawn_timer: Timer = $SpawnTimer

var spawn_time_idx := 0
var record_target: FallingRock
var fall_positions := Curve2D.new()


func _ready() -> void:
	assert(spawn_times.size() > 0, "need at least one spawn timer")
	fall_positions.clear_points()
	self.rock_spawned.connect(_on_rock_spawned, CONNECT_ONE_SHOT)
	_start_spawn_next_timer()


func _on_rock_spawned(rock: FallingRock) -> void:
	record_target = rock
	record_target.tree_exited.connect(_save_fall_recording)


func _physics_process(_delta: float) -> void:
	if is_instance_valid(record_target) and record_target.is_inside_tree():
		fall_positions.add_point(to_local(record_target.global_position))


func _start_spawn_next_timer() -> void:
	spawn_time_idx = spawn_time_idx % spawn_times.size()
	spawn_time_idx = clampi(spawn_time_idx, 0, spawn_times.size())
	var spawn_time: float = spawn_times.get(spawn_time_idx)
	spawn_timer.start(spawn_time)
	spawn_time_idx += 1


func _on_spawn_timer_timeout() -> void:
	spawn_rock()
	_start_spawn_next_timer()


func spawn_rock() -> FallingRock:
	var rock: FallingRock = FALLING_ROCK.instantiate()
	rock.global_position = self.global_position
	rock.linear_velocity = inital_velocity
	get_parent().add_child(rock)
	rock_spawned.emit(rock)
	return rock


func _save_fall_recording() -> void:
	var save_path := "res://falling_rock/%s.tres" % self.name
	print("record falling rock path to: " + save_path)
	ResourceSaver.save(fall_positions, save_path)
