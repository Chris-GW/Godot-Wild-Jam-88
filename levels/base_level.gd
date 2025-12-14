class_name BaseLevel 
extends Node2D

@export var level_resource: LevelResource

@onready var map_root: Node2D = %MapRoot
@onready var player: Player = %Player
@onready var player_camera: Camera2D = %PlayerCamera2D

@onready var health_progress_bar: ProgressBar = %HealthProgressBar
@onready var stamina_progress_bar: ProgressBar = %StaminaProgressBar
@onready var flashlight_progress_bar: ProgressBar = %FlashlightProgressBar

var needed_repair_count := 0


func _ready() -> void:
	assert(level_resource != null, "not null level_resource")
	%DeathPanel.hide()
	%LevelWinPanel.hide()
	
	health_progress_bar.max_value = player.max_health
	health_progress_bar.value = player.health
	
	stamina_progress_bar.max_value = player.max_stamina
	stamina_progress_bar.value = player.stamina
	
	flashlight_progress_bar.max_value = player.flash_light.max_battery
	flashlight_progress_bar.value = player.flash_light.battery
	
	for repair_target: RepairTarget in get_tree().get_nodes_in_group("repair_targets"):
		repair_target.repaired.connect(_on_target_repaired)
		if repair_target.required_repair:
			needed_repair_count += 1


func _process(_delta: float) -> void:
	health_progress_bar.value = player.health
	stamina_progress_bar.value = player.stamina
	flashlight_progress_bar.value = player.flash_light.battery


func _on_target_repaired(_target: RepairTarget) -> void:
	needed_repair_count -= 1
	if needed_repair_count <= 0:
		_on_level_win()


func _on_player_died() -> void:
	%DeathPanel.show()
	get_tree().paused = true

func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_abort_level_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://ui/level_select_menu/level_select_menu.tscn")


func _on_level_win() -> void:
	Global.unlocked_levels = maxi(Global.unlocked_levels, level_resource.index + 1)
	%LevelWinPanel.show()
	get_tree().paused = true

func _on_finish_level_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://ui/level_select_menu/level_select_menu.tscn")
