extends Node

@export var rock_spawner: FallingRockSpawner
@onready var repair_target: RepairTarget = get_parent()


func _ready() -> void:
	repair_target.repaired.connect(_on_repaired)


func _on_repaired(_target: RepairTarget) -> void:
	rock_spawner.spawn_times = [3.0, 2.5, 0.4]
