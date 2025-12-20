extends Node

@export var rock_spawner: FallingRockSpawner
@onready var repair_target: RepairTarget = get_parent()


func _ready() -> void:
	repair_target.repaired.connect(_on_repaired)


func _on_repaired(_target: RepairTarget) -> void:
	rock_spawner.spawn_times.clear()
	rock_spawner.spawn_times.append(3.0)
	rock_spawner.spawn_times.append(2.5)
	rock_spawner.spawn_times.append(0.4)
