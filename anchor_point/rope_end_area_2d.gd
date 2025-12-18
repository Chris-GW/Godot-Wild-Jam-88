class_name RopeEndArea2D extends Area2D

@onready var highlight = $Highlight

var _can_interact = false

signal interacting_with_rope_end

func _ready():
	highlight.hide()

func do_interaction():
	#print("interacting with rope_end")
	interacting_with_rope_end.emit()

func can_interact():
	return _can_interact

func select_for_interaction() -> void:
	highlight.show()

func unselect_for_interaction() -> void:
	highlight.hide()
