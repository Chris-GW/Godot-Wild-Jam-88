extends Node2D

var edges := Vector2.ZERO

func set_edges(v: Vector2):
	edges = v
	queue_redraw()

func _draw():
	draw_rect(Rect2(0, 0, edges.x, edges.y), Color.WHITE, false)
