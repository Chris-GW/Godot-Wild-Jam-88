extends Node

var unlocked_levels := 0

func _process(delta) -> void:
	if Input.is_action_pressed("debug_reload"):
		get_tree().reload_current_scene()

func find_node_if_type(node: Node, predicate: Callable) -> Node:
	for child in node.get_children():
		if predicate.call(child):
			return child
		var recursive_found: Node = find_node_if_type(child, predicate)
		if recursive_found != null:
			return recursive_found
	return null
