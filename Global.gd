extends Node

var unlocked_levels := 0


func _ready() -> void:
	if OS.is_debug_build():
		unlocked_levels = 99


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_reload"):
		get_tree().reload_current_scene()
		FogOfWar.reset_fog()


func find_node_if_type(node: Node, predicate: Callable) -> Node:
	for child in node.get_children():
		if predicate.call(child):
			return child
		var recursive_found: Node = find_node_if_type(child, predicate)
		if recursive_found != null:
			return recursive_found
	return null
