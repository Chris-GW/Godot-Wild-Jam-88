class_name BaseLevel 
extends Node2D

@export var level_resource: LevelResource

@onready var map_root: Node2D = %MapRoot
var player
#@onready var player_camera: Camera2D = %PlayerCamera2D

@onready var hud: Hud = %HudCanvasLayer
# TODO: move to the HUDCanvasLayer so that baselayer only know about the HUD
# Have the HUD manage the bars
# @onready var health_progress_bar: ProgressBar = %HealthProgressBar
# @onready var stamina_progress_bar: ProgressBar = %StaminaProgressBar
# @onready var flashlight_progress_bar: ProgressBar = %FlashlightProgressBar

var needed_repair_count := 0

func assign_player():
	var players = get_tree().get_nodes_in_group("player")
	
	# if you want to use a different scene for the player:
	# TODO: this isn't modular yet  because some nodes specifically require PlayerStateMachine
	# to be the player.
	for p in players.size():
		print(players[p])
		if players[p] is PlayerStateMachine:
			print("player is now the state machine")
			player = players[p]
		elif players[p] is Player:
			pass # player is now Player
				 # etc... 
			
	
func _ready() -> void:
	assert(level_resource != null, "not null level_resource")
	%DeathPanel.hide()
	%LevelWinPanel.hide()

	assign_player()
	print("player is : ", player, " from base_level.")
	assert(player != null, "null player resource")

	
	hud.set_health(player.max_health)
	hud.set_stamina(player.max_stamina)
	hud.set_flashlight(player.flash_light.battery)
	
	for repair_target: RepairTarget in get_tree().get_nodes_in_group("repair_targets"):
		repair_target.repaired.connect(_on_target_repaired)
		if repair_target.required_repair:
			needed_repair_count += 1


func _process(_delta: float) -> void:
	hud.set_health(player.health)
	hud.set_stamina(player.stamina)
	hud.set_flashlight(player.flash_light.battery)


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
