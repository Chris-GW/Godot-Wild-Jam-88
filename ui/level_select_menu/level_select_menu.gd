extends Control

const LEVEL_SELECT_BUTTON = preload("uid://bupyqfgj0x1rx")
const LEVEL_RESOURCES = [
	preload("res://levels/level_resources/level_00_resource.tres"),
	preload("res://levels/level_resources/level_01_resource.tres"),
	preload("res://levels/level_resources/level_02_resource.tres"),
]

@onready var level_buttons: VBoxContainer = %LevelButtons
@onready var level_title: Label = %LevelTitle
@onready var level_text: RichTextLabel = %LevelText


func _ready() -> void:
	_build_level_buttons()
	var level_idx = clampi(Global.unlocked_levels, 0, level_buttons.get_child_count() - 1)
	var level_button: = level_buttons.get_child(level_idx)
	_on_level_selected.call_deferred(level_button.level_resource)


func _build_level_buttons() -> void:
	for child in level_buttons.get_children():
		level_buttons.remove_child(child)
		child.queue_free()
	
	for level_resouce: LevelResource in LEVEL_RESOURCES:
		var level_button: LevelSelectButton = LEVEL_SELECT_BUTTON.instantiate()
		level_button.level_resource = level_resouce
		level_button.level_selected.connect(self._on_level_selected)
		level_buttons.add_child(level_button)


func _on_level_selected(level_resource: LevelResource) -> void:
	level_title.text = level_resource.name
	level_text.text = level_resource.text
	for child in level_buttons.get_children():
		child.set_pressed(child.level_resource.index == level_resource.index)


func _on_start_button_pressed() -> void:
	for child in level_buttons.get_children():
		if child is LevelSelectButton and child.is_pressed():
			var level_resouce: LevelResource = child.level_resource
			get_tree().change_scene_to_file(level_resouce.scene_path)
			return


func _on_back_button_pressed() -> void:
	print("back_to_menu")
