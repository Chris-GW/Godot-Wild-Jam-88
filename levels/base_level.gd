class_name BaseLevel 
extends Node2D

@onready var y_sort_root: Node2D = %YSortRoot
@onready var player: Player = %Player
@onready var player_camera: Camera2D = %PlayerCamera2D

@onready var health_progress_bar: ProgressBar = %HealthProgressBar


func _ready() -> void:
	health_progress_bar.max_value = player.max_health
	health_progress_bar.value = player.health
	player.health_changed.connect(self.update_health_progress_bar)


func update_health_progress_bar() -> void:
	health_progress_bar.value = player.health
