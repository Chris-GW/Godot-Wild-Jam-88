extends Label

func move_above_player(player_controller):
	global_position = player_controller.global_position + Vector2(0,-150)

func show_floating(text_to_show: String) -> void:
	text = text_to_show
	modulate.a = 0.0              # start invisible
	position.y += 10              # start slightly lower
	show()

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	# Fade in + move up
	tween.tween_property(self, "modulate:a", 1.0, 0.2)
	tween.parallel().tween_property(self, "position:y", position.y - 10.0, 0.2)

	# Wait visible for a bit
	tween.tween_interval(0.5)

	# Fade out + move a bit more
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.parallel().tween_property(self, "position:y", position.y - 20.0, 0.3)

	tween.tween_callback(hide)
