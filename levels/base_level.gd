class_name BaseLevel 
extends Node2D

@onready var map_root: Node2D = %MapRoot
@onready var player: Player = %Player
@onready var player_camera: Camera2D = %PlayerCamera2D

@onready var health_progress_bar: ProgressBar = %HealthProgressBar
@onready var stamina_progress_bar: ProgressBar = %StaminaProgressBar
@onready var flashlight_progress_bar: ProgressBar = %FlashlightProgressBar


func _ready() -> void:
	health_progress_bar.max_value = player.max_health
	health_progress_bar.value = player.health
	player.health_changed.connect(self.update_health_progress_bar)
	
	stamina_progress_bar.max_value = player.max_stamina
	stamina_progress_bar.value = player.stamina
	
	flashlight_progress_bar.max_value = player.flash_light.max_battery
	flashlight_progress_bar.value = player.flash_light.battery


func _process(_delta: float) -> void:
	stamina_progress_bar.value = player.stamina
	flashlight_progress_bar.value = player.flash_light.battery


func update_health_progress_bar() -> void:
	health_progress_bar.value = player.health
