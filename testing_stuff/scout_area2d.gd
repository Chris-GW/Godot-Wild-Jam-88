class_name Scout_Area2D extends Area2D

@onready var highlight: Node2D = $Highlight

var _can_interact = true

signal interacting_with_scout

func _ready():
	highlight.hide()

func do_interaction():
	interacting_with_scout.emit()

func can_interact():
	return _can_interact

func select_for_interaction() -> void:
	highlight.show()

func unselect_for_interaction() -> void:
	highlight.hide()
