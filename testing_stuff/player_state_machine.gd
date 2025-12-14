class_name PlayerStateMachine extends Node

## Definitions of Player States ##
class State extends Node:
	var name_str: String
	var machine = null
		
	func _init(_machine, n: String):
		machine = _machine
		name_str = n

	func enter():
		pass
	func run(delta):
		pass
	func exit():
		pass
	func handle_input(event):
		pass

class FallingState extends State:
	var frame_count = 0.0
	var coyote_limit = 0.5
	var prev_state
	var next_state
	var sprint_pressed = false

	func _init(_machine, n: String):
		machine = _machine
		name_str = n
		machine.sprint_pressed.connect(_on_sprint_pressed)
		machine.sprint_released.connect(_on_sprint_released)
	
	func enter():
		frame_count = 0.0
		prev_state = machine.prev_state
		match prev_state:
			machine.walking_state:
				next_state = machine.walking_state
			machine.sprinting_state:
				next_state = machine.sprinting_state	
			_:
				if sprint_pressed:
					next_state = machine.sprinting_state
				else:
					next_state = machine.walking_state

		
	func run(delta):
		frame_count += delta
		
		machine.player_controller.apply_gravity(delta)
		machine.player_controller.move_and_slide()

		if machine.player_controller.is_on_floor():
			machine.change_state(next_state)

	func _on_sprint_pressed(b):
		sprint_pressed = b
		next_state = machine.sprinting_state
		#print("sprint? ", sprint_pressed)
	func _on_sprint_released(b):
		sprint_pressed = b
		#print("sprint? ", sprint_pressed)
			
	func handle_input(event):
		if frame_count <= coyote_limit and event.is_action_pressed("jump"):
			machine.change_state(machine.jumping_state)

		if event.is_action_pressed("debug_sprint"):
			next_state = machine.sprinting_state
		if event.is_action_released("debug_sprint"):
			next_state = machine.walking_state
			
class WalkingState extends State:
	var speed = 450.0
	
	func run(delta):
		machine.player_controller.move(speed, delta)

		if not  machine.player_controller.is_on_floor():
			machine.change_state(machine.falling_state)

	func handle_input(event):
		if event.is_action_pressed("debug_sprint"):
			machine.change_state(machine.sprinting_state)

		elif event.is_action_pressed("jump") and machine.player_controller.is_on_floor():
			machine.change_state(machine.jumping_state)
	
	func exit():
		pass

class SprintingState extends State:
	var speed = 900.0
	
	func run(delta):
		machine.player_controller.move(speed, delta)

		if not  machine.player_controller.is_on_floor():
			machine.change_state(machine.falling_state)

		
	func handle_input(event):
		if event.is_action_pressed("jump") and machine.player_controller.is_on_floor():
			machine.change_state(machine.jumping_state)

		if event.is_action_released("debug_sprint"):
			machine.change_state(machine.walking_state)
		
	func exit():
		pass

class JumpingState extends State:
	var frames_in_air := 0
	#var speed = 100.0
	var speed = 0.0
	var walk_speed = -700.0
	var sprint_speed = -800.0
	var next_state
	var prev_state
	var input_direction
	var target_x_speed = 0.0
	var accel = 40.0
	
	func enter():
		prev_state = machine.prev_state
		print("prev_state: ", prev_state.name_str)
		match prev_state:
			machine.sprinting_state:
				speed = sprint_speed
			machine.walking_state:
				speed = walk_speed
		print("speed in jump state: ", speed )
		machine.player_controller.jump(speed)
		next_state = prev_state # i just want to go back to prev state unless handle_input (see below)
	
		input_direction = Input.get_vector("move_left","move_right","ui_up","ui_down")
		target_x_speed = input_direction.x * speed
	
	func run(delta):
		machine.player_controller.apply_gravity(delta)
		
		input_direction = Input.get_vector("move_right","move_left","ui_up","ui_down")
		target_x_speed = input_direction.x * speed
		machine.player_controller.velocity.x = move_toward(machine.player_controller.velocity.x, target_x_speed, accel)
		machine.player_controller.move_and_slide()

		if machine.player_controller.is_on_floor():
			machine.change_state(next_state)
			
	func handle_input(event):
		if event.is_action_released("debug_sprint"):
			next_state = machine.walking_state
		if event.is_action_pressed("debug_sprint"):
			next_state = machine.sprinting_state

	func exit():
		pass


	
@onready var player_controller: CharacterBody2D = $test_player_controller
signal changing_state(state)
signal sprint_pressed(true_false)
signal sprint_released(true_false)

var current_state : State
var prev_state : State
var walking_state
var sprinting_state
var jumping_state
var falling_state
func _init() -> void:
	pass
func _ready() -> void:
	walking_state = WalkingState.new(self, "walking_state")
	sprinting_state = SprintingState.new(self, "sprinting_state")
	jumping_state = JumpingState.new(self, "jumping_state")
	falling_state = FallingState.new(self, "falling_state")
	current_state = walking_state
	prev_state = walking_state

	changing_state.connect(_on_changing_state)

	print("current state: ", current_state.name_str)
	
func _physics_process(delta):
	current_state.run(delta)
		
func change_state(s: State):
	prev_state = current_state
	current_state.exit()
	current_state = s
	s.enter()
	print("changing to state:", current_state.name_str)
	changing_state.emit(current_state)

func _on_changing_state(state):
	pass

func _unhandled_input(event):
	current_state.handle_input(event)

	if event.is_action_pressed("debug_add_anchor"):
		print("add anchor")
	if event.is_action_pressed("debug_sprint"):
		sprint_pressed.emit(true)
	if event.is_action_released("debug_sprint"):
		sprint_released.emit(false)
		

	
