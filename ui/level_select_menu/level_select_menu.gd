extends Control

const LEVEL_SELECT_BUTTON = preload("uid://bupyqfgj0x1rx")
const LEVEL_RESOURCES = [
	preload("res://levels/level_resources/level_01_resource.tres"),
	preload("res://levels/level_resources/level_02_resource.tres"),
]

@onready var level_buttons: VBoxContainer = %LevelButtons
@onready var level_title: Label = %LevelTitle
@onready var level_text: RichTextLabel = %LevelText

var select_level_button_group := ButtonGroup.new()


func _ready() -> void:
	_build_level_buttons()


func _build_level_buttons() -> void:
	for child in level_buttons.get_children():
		level_buttons.remove_child(child)
		child.queue_free()
	select_level_button_group = ButtonGroup.new()
	
	for level_resouce: LevelResource in LEVEL_RESOURCES:
		var level_button: LevelSelectButton = LEVEL_SELECT_BUTTON.instantiate()
		level_button.level_resource = level_resouce
		level_button.button_group = select_level_button_group
		level_button.level_selected.connect(self._on_level_selected)
		level_buttons.add_child(level_button)
		
		if level_resouce.index == Global.unlocked_levels:
			_on_level_selected.call_deferred(level_resouce)
			level_button.set_pressed.call_deferred(true)


func _on_level_selected(level_resource: LevelResource) -> void:
	level_title.text = level_resource.name
	level_text.text = level_resource.text


func _on_start_button_pressed() -> void:
	var pressed_level_button: LevelSelectButton = select_level_button_group.get_pressed_button()
	var level_resouce := pressed_level_button.level_resource
	get_tree().change_scene_to_file(level_resouce.scene_path)


func _on_back_button_pressed() -> void:
	print("back_to_menu")
