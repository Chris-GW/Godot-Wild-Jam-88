class_name PlayerStateMachine extends Node2D

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
	var acceleration = 0.1
	var deceleration = 0.1
	var speed = 300.0

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

		if machine.player_controller.is_on_floor():
			machine.change_state(next_state)

		update_horizontal_velocity()
		machine.player_controller.move_and_slide()


	func update_horizontal_velocity() -> void:
		var direction := Input.get_axis("move_left", "move_right")
		if is_zero_approx(direction):
			machine.player_controller.velocity.x = lerpf(machine.player_controller.velocity.x, 0.0, deceleration)
		else:
			machine.player_controller.velocity.x = lerpf(machine.player_controller.velocity.x, direction * speed, acceleration)
			
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

		machine.stamina += machine.stamina_recover_per_second * delta
		machine.stamina = clampf(machine.stamina, 0.0, machine.max_stamina)

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
		#print("prev_state: ", prev_state.name_str)
		match prev_state:
			machine.sprinting_state:
				speed = sprint_speed
			machine.walking_state:
				speed = walk_speed
		#print("speed in jump state: ", speed )
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

class GrapplingState extends State:
	var next_state
	var can_launch = true
	var acceleration = 0.1
	var deceleration = 0.1
	var speed = 300.0

	func _init(_machine, n: String):
		machine = _machine
		name_str = n
		machine.stamina_depleted.connect(_on_stamina_depleted)
	
	func enter():
		machine.grapple_control.rope_line.show()
		next_state = machine.falling_state
		
	func run(delta):
		machine.player_controller.apply_gravity(delta)
		machine.grapple_control.handle_grapple(delta)

		if Input.is_action_just_pressed("reel_in_rope"):
			machine.grapple_control.reel_in_rope(delta)
		if Input.is_action_pressed("let_out_rope"):
			machine.grapple_control.let_out_rope(delta)

		machine.grapple_control.update_rope()

		var stamina_percent =  machine.stamina / machine.max_stamina
		if stamina_percent > 0.15:
			can_launch = true
		else:
			can_launch = false

		update_horizontal_velocity()
		update_stamina(delta)
		machine.player_controller.move_and_slide()

	func update_horizontal_velocity() -> void:
		var direction := Input.get_axis("move_left", "move_right")
		if is_zero_approx(direction):
			machine.player_controller.velocity.x = lerpf(machine.player_controller.velocity.x, 0.0, deceleration)
		else:
			machine.player_controller.velocity.x = lerpf(machine.player_controller.velocity.x, direction * speed/2.0, acceleration)

	func _on_stamina_depleted():
		machine.change_state(machine.falling_state)
		
	func update_stamina(delta: float) -> void:
		machine.stamina -= machine.stamina_drain_per_second * delta
		machine.stamina = clampf(machine.stamina, 0.0, machine.max_stamina)
		if is_zero_approx(machine.stamina):
			machine.stamina_depleted.emit()

	func handle_input(event):
		if event.is_action_pressed("jump"):
			#TODO: figure out what state comes next
			machine.change_state(next_state)

	func exit():
		machine.grapple_control.retract()
	

	
@onready var player_controller: CharacterBody2D = $test_player_controller
signal changing_state(state)
signal sprint_pressed(true_false)
signal sprint_released(true_false)

signal stamina_depleted()
signal is_interacting(node: Node)

var current_state : State
var prev_state : State
var walking_state
var sprinting_state
var jumping_state
var falling_state
var grappling_state

var max_health:= 100
var health = 100
var stamina = 100.0
var max_stamina = 100.0
var stamina_drain_per_second = 15.0
var stamina_recover_per_second = 30.0

var flash_light: FlashLight
var grapple_control: GrappleControl


var interactables_in_reach = []

func _init() -> void:
	pass
func _ready() -> void:
	# create instances of all the states
	walking_state = WalkingState.new(self, "walking_state")
	sprinting_state = SprintingState.new(self, "sprinting_state")
	jumping_state = JumpingState.new(self, "jumping_state")
	falling_state = FallingState.new(self, "falling_state")
	grappling_state = GrapplingState.new(self, "grappling_state")
	current_state = walking_state
	prev_state = walking_state

	# sometimes i have to change the state from this upper level, instead of inside the current state
	changing_state.connect(_on_changing_state)
	is_interacting.connect(_on_interacting)
	player_controller.taking_collision_damage.connect(_on_taking_collision_damage)
	player_controller.hitting_wall.connect(_on_hitting_wall)
	player_controller.hitting_floor.connect(_on_hitting_floor)
	
	flash_light = find_node_if_type(self, func(n): return n is FlashLight)
	if flash_light:
		print("flashlight from player: ", flash_light)
	else:
		print("no flashlight found")

	grapple_control = find_node_if_type(self, func(n): return n is GrappleControl)
	if grapple_control:
		print("grapple control from player: ", grapple_control)
	else:
		print("no grapple control found")

func _on_taking_collision_damage(dmg: int):
	print("receiving collision damage in playerstatemachine: ", dmg)

func _on_hitting_floor(vec2, collider):
	#print("HITTING FLOOR in statemachine: ", collider)
	pass

func _on_hitting_wall(vec2, collider):
	# TODO : use to implement a wall slide mechanic??
	# NOTE: a steep static body is preventing my player from falling down in falling_state
	#print("HITTING WALL in statemachine: ", collider)
	if current_state == falling_state:
		#current_state == wall_sliding_state
		pass

# I also added this as a Global function. helpful for finding child nodes without direct path,
# if you only need a single node of a single type
func find_node_if_type(node: Node, predicate: Callable) -> Node:
	for child in node.get_children():
		if predicate.call(child):
			return child
		var recursive_found: Node = find_node_if_type(child, predicate)
		if recursive_found != null:
			return recursive_found
	return null

func _physics_process(delta):
	current_state.run(delta)
	highlight_nearest_interactable()
		
func highlight_nearest_interactable() -> void:
	for interactable in interactables_in_reach:
		interactable.call("unselect_for_interaction")
	
	var interactables := interactables_in_reach.filter(func(interactable):
		return interactable.call("can_interact"))
	interactables.sort_custom(sort_by_distance)
	if not interactables.is_empty():
		var nearest_interactable = interactables.front()
		nearest_interactable.call("select_for_interaction")

		
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

	if event.is_action_pressed("interact"):
		#print("pressing interact")
		interact()
	

func take_damage(damage: int) -> void:
	change_health(-damage)
	
func change_health(amount: int) -> void:
	health += amount
	health = clampi(health, 0, max_health)
	if health <= 0:
		die()

func die():
	print("you are dead now")

func interact() -> void:
	var interactables := interactables_in_reach.filter(func(interactable):
		return interactable.call("can_interact"))
	interactables.sort_custom(sort_by_distance)
	if not interactables.is_empty():
		var nearest_interactable = interactables.front()
		# NOTE: here is where I call a signal and then connect in the specific
		# states where I want
		# example: emit_signal inside anchor_point.do_interaction(self)
		nearest_interactable.call("do_interaction")
		print("nearest_interactable: ", nearest_interactable)

func _on_interacting(node: Node2D):
	print("_on_interacting: ", node)
	if node is AnchorPoint:
		# NOTE: is this where we switch to the Grappling state?
		# TODO: or emit a signal which is picked up in the states themselves
		#print("we got anchorpoint: ", node)
		change_state(grappling_state)

	if node is RepairTarget:
		# TODO: switch to Repairing state to manage repair animations etc (if needed)
		print("getting repair target")
		
		
func sort_by_distance(a: Node2D, b : Node2D) -> bool:
	var distance_a := self.global_position.distance_squared_to(a.global_position)
	var distance_b := self.global_position.distance_squared_to(b.global_position)
	return distance_a < distance_b

func add_interactable(interactable: Node2D) -> void:
	print("add_interactable ", self)
	interactables_in_reach.append(interactable)

func remove_interactable(interactable: Node2D) -> void:
	#print("remove_interactable", self)
	interactables_in_reach.erase(interactable)
