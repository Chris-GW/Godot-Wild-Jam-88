class_name LevelSelectButton
extends Button

signal level_selected(level_resource: LevelResource)

@export var level_resource: LevelResource


func _ready() -> void:
	self.text = level_resource.name
	self.disabled = Global.unlocked_levels < level_resource.index


func _on_pressed() -> void:
	level_selected.emit(level_resource)
