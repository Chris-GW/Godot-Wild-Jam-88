extends Node


func _on_repair_target_repaired(target: RepairTarget) -> void:
	self.queue_free()
