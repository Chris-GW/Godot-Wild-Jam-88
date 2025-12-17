@tool
extends OverlaidWindowContainer

func _ready() -> void:
	super._ready()
	if instance and instance.has_signal(&"end_reached"):
		instance.connect(&"end_reached", close)
