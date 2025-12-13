class_name MoverController extends Node

var edges = Vector2(200,4000)

var movers = []

@export var main_mover: Mover

#@export var camera: Camera2D

@onready var edge_drawer: Node2D = $EdgeDrawer

func _ready():
	edge_drawer.set_edges(edges)

	main_mover.edges = edges
	movers.append(main_mover)

func cannon_shot() -> Vector2:
	var angle := deg_to_rad(-30.0)
	var dir := Vector2(cos(angle), sin(angle)).normalized()
	var impulse := dir * 400.0
	return impulse

func get_forward_dir(mover) -> Vector2:
	var a = mover.rotation
	var dir = Vector2.RIGHT.rotated(a)
	return dir
 
var timer = 0.0
var timelimit = 0.5
func _process(delta) -> void:
	for m in movers.size():
		var mvr = movers[m]
		mvr.gravity()

	timer += delta
	if timer > timelimit:
		timer = 0.0

	
	var iv = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	for m in movers.size():
		movers[m].apply_force(iv * 5000.0)
		
func _unhandled_input(event:InputEvent) -> void:
	#pass
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and !event.pressed:
			pass

	if event.is_action_pressed("debug_reload"):
		get_tree().reload_current_scene()
