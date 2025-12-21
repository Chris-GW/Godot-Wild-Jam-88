extends Node

@export var light_nodes: Node2D
@onready var repair_target: RepairTarget = get_parent()


func _ready() -> void:
	light_nodes.hide()
	repair_target.repaired.connect(_on_repaired)


func _on_repaired(_target: RepairTarget) -> void:
	light_nodes.show()
