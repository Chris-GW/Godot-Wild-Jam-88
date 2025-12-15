extends PanelContainer


func _ready() -> void:
	%QuitButton.visible = not OS.has_feature("web")
	hide()


func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		visible = not visible
		get_tree().paused = visible


func _on_continue_button_pressed() -> void:
	get_tree().paused = false
	hide()


func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_settings_button_pressed() -> void:
	get_tree().paused = false
	print("_on_settings_button_pressed")


func _on_abort_level_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://ui/level_select_menu/level_select_menu.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
