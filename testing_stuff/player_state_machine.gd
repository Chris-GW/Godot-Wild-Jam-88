class_name PlayerStateMachine extends Node2D

## Definitions of Player States ##
class State extends Node:
	var name_str: String
	var machine = null
	var anim: AnimatedSprite2D
	
	func _init(_machine, n: String):
		machine = _machine
		name_str = n
		anim = machine.anim

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
	var current_anim = ""

	func set_anim(name: String):
		if name == current_anim:
			return
		print("setting anim: ", name)
		current_anim = name
		anim.play(name)
	
	func run(delta):
		var input = Input.get_vector("move_left", "move_right", "ui_up", "ui_down")
		if input == Vector2.ZERO:
			set_anim("idle")
			anim.flip_h = input.x < 0.0
		else:
			set_anim("walk")
			
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

		if event.is_action_pressed("debug_scout"):
			machine.change_state(machine.scouting_state)
	
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

	var rest_length
	var max_rope_length = 400.0
	var reel_in_speed = 120.0
	var let_out_speed = 120.0

	var current_anchor = null
	#var prev_anchor = null
	#var next_anchor = null
	
	func _init(_machine, n: String):
		machine = _machine
		name_str = n
		machine.stamina_depleted.connect(_on_stamina_depleted)
		machine.changing_anchor_point.connect(_on_anchor_point_changed)
	
	func enter():
		#machine.grapple_control.rope_line.show()
		next_state = machine.falling_state
		current_anchor.is_attached = true
		current_anchor.rope_end.freeze = true
		rest_length = machine.player_controller.global_position.distance_to(current_anchor.global_position) 
		rest_length += 64.0 
		rest_length = clampf(rest_length, 0.0, max_rope_length)
		current_anchor.rope_line.show()
		
	func run(delta):
		machine.player_controller.apply_gravity(delta)
		#machine.grapple_control.handle_grapple(delta)
		handle_grapple(delta)
		
		if Input.is_action_pressed("reel_in_rope"):
			reel_in_rope(delta)
		if Input.is_action_pressed("let_out_rope"):
			let_out_rope(delta)
	
		#update_rope(current_anchor)

		var stamina_percent =  machine.stamina / machine.max_stamina
		if stamina_percent > 0.15:
			can_launch = true
		else:
			can_launch = false

		update_horizontal_velocity()
		update_stamina(delta)

		machine.player_controller.move_and_slide()

	func update_rope(anchor: AnchorPoint) -> void:
		var rope = anchor.rope_line
		var start = rope.to_local(machine.player_controller.global_position)
		rope.set_point_position(0,start)
		var end = rope.to_local(anchor.global_position)
		rope.set_point_position(1,end)
		
	var stiffness = 120.0
	var damping = 20.0
	# how and where to set rest	length? and what is it?
	
	func handle_grapple(delta: float) -> void:
		var target = current_anchor.global_position
		var target_direction =machine.player_controller.global_position.direction_to(target)
		var target_distance = machine.player_controller.global_position.distance_to(target)
		var displacement = target_distance - rest_length

		if displacement <= 0.0001:
			return
		var spring_force_magnitude = stiffness * displacement
		var spring_force = target_direction * spring_force_magnitude

		var velocity_dot = machine.player_controller.velocity.dot(target_direction)
		var damping_force = -damping * velocity_dot * target_direction
		var force = spring_force + damping_force
		machine.player_controller.velocity += force * delta

	func _on_anchor_point_changed(anchor: AnchorPoint):
		pass
		#next_anchor = anchor
		#current_anchor = anchor
		
	func reel_in_rope(delta: float) -> void:
		rest_length -= reel_in_speed * delta
		rest_length = maxf(rest_length, 0.0)
		#print(rest_length, " reel_in_rope")

	func let_out_rope(delta: float) -> void:
		rest_length += let_out_speed * delta
		rest_length = minf(rest_length, max_rope_length)
		#print(rest_length, " let_out_rope")
		
	func set_current_anchor(anchor):
		current_anchor = anchor
		
	func update_horizontal_velocity() -> void:
		var direction := Input.get_axis("move_left", "move_right")
		if is_zero_approx(direction):
			machine.player_controller.velocity.x = lerpf(machine.player_controller.velocity.x, 0.0, deceleration)
		else:
			machine.player_controller.velocity.x = lerpf(machine.player_controller.velocity.x, direction * speed, acceleration)

	func _on_stamina_depleted():
		current_anchor.detach(machine.player_controller.global_position)
		machine.change_state(machine.falling_state)
		
	func update_stamina(delta: float) -> void:
		machine.stamina -= machine.stamina_drain_per_second * delta
		machine.stamina = clampf(machine.stamina, 0.0, machine.max_stamina)
		if is_zero_approx(machine.stamina):
			machine.stamina_depleted.emit()

	func handle_input(event):
		if event.is_action_pressed("jump"):
			#TODO: figure out what state comes next
			current_anchor.detach(machine.player_controller.global_position)
			machine.change_state(next_state)
			
	func exit():
		pass
		#current_anchor.detach(machine.player_controller.global_position)

class ScoutingState extends State:
	var scout
	var mover
	var scout_camera: FollowCamera
	var battery_max = 100.0
	var battery = battery_max
	var battery_drain_speed = 2.0
	var scout_flashlight
	
	func _init(_machine, _name):
		machine = _machine
		name_str = _name

		scout = machine.SCOUT.instantiate()
		mover = scout.get_node("Mover")
		mover.in_the_world = false
		
		machine.add_child(scout)
		scout.hide()

		mover.scout_area2d.set_monitoring(false) 

		scout_camera = FollowCamera.new()
		scout_camera.follow_target = mover
		machine.add_child(scout_camera)
		scout_flashlight = Global.find_node_if_type(mover, func(n): return n is FlashLight)
		if not scout_flashlight:
			print("NO SCOUT FLASHLIGHT")
		
	func enter():
		var pos = machine.player_controller.global_position+ Vector2(100,-100)
		if mover.in_the_world:
			scout_camera.global_position = pos
		else:
			if not scout.is_visible():
				scout.show()
			mover.global_position = pos
			scout_camera.global_position = pos
			mover.in_the_world = true
			machine.scout_in_inventory = false
			mover.scout_area2d.set_monitoring(true)
			
			
		mover.acceleration = Vector2.ZERO
		mover.velocity = Vector2.ZERO
		mover.active = true
		mover.collider.disabled = false
		scout_camera.make_current()
	
	func run(delta):
		if battery > 0:
			var iv = Input.get_vector("move_left", "move_right", "move_up", "move_down")
			mover.apply_force(iv * 250.0)

		battery -= delta * battery_drain_speed * battery_drain_speed
		if battery <= 0:
			print("SCOUT BATTERY DRAINED")
			machine.change_state(machine.walking_state)
		battery = clampf(battery, 0.0, battery_max)

		set_battery_bar(battery / battery_max)

	func recharge():
		if not mover.in_the_world:
			battery = battery_max
		
	func set_battery_bar(val: float):
		val = clampf(val,0.0,1.0)
		update_bar(val)
		
	func update_bar(val: float):
		var h = 10.0
		var max_fill_width = 80.0
		mover.battery_remain.size = Vector2(val * max_fill_width, h)
		
	func handle_input(event):
		if event.is_action_pressed("debug_scout"):
			machine.change_state(machine.walking_state)
		
	func exit():
		mover.active = false
		machine.player_camera.make_current()
		mover.velocity = Vector2.ZERO
		mover.acceleration = Vector2.ZERO

## BEGIN STATE MACHINE PROPER ## 
	
const ANCHOR_POINT = preload("uid://0k877ukwywbb")
const SCOUT = preload("uid://brhryu6q8dwuy")
var scout_in_inventory := true

@onready var anim: AnimatedSprite2D = $test_player_controller/AnimatedSprite2D_Diffuse
@onready var player_camera = $FollowCamera
@onready var player_controller: CharacterBody2D = $test_player_controller
signal changing_state(state)
signal sprint_pressed(true_false)
signal sprint_released(true_false)

signal died()
signal stamina_depleted()
signal is_interacting(node: Node)

var current_state : State
var prev_state : State
var walking_state
var sprinting_state
var jumping_state
var falling_state
var grappling_state
var scouting_state

var max_health:= 100
var health = 100
var max_stamina = 100.0
var stamina = max_stamina
var stamina_drain_per_second = 12.0
var stamina_recover_per_second = 30.0

var flash_light: FlashLight
var grapple_control: GrappleControl
@onready var invulnerable_timer: Timer = $InvulnerableTimer

var interactables_in_reach = []

func _init() -> void:
	pass
func _ready() -> void:
	#print("player_cam: ", player_camera)
	#print(ANCHOR_POINT)
	# create instances of all the states
	walking_state = WalkingState.new(self, "walking_state")
	sprinting_state = SprintingState.new(self, "sprinting_state")
	jumping_state = JumpingState.new(self, "jumping_state")
	falling_state = FallingState.new(self, "falling_state")
	grappling_state = GrapplingState.new(self, "grappling_state")
	scouting_state = ScoutingState.new(self, "scouting_state")
	current_state = walking_state
	prev_state = walking_state

	# sometimes i have to change the state from this upper level, instead of inside the current state
	changing_state.connect(_on_changing_state)
	is_interacting.connect(_is_interacting)
	player_controller.taking_collision_damage.connect(_on_taking_collision_damage)
	player_controller.hitting_wall.connect(_on_hitting_wall)
	player_controller.hitting_floor.connect(_on_hitting_floor)
	scouting_state.mover.scout_area2d.interacting_with_scout.connect(_on_interacting_with_scout)
	
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
	change_health(-dmg)

func _on_hitting_floor(vec2, collider):
	#print("HITTING FLOOR in statemachine: ", collider)
	pass

func _on_hitting_wall(vec2, collider):
	# TODO : use to implement a wall slide mechanic??
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
		#print("nearest_interactable: ", nearest_interactable)
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
		var ap = ANCHOR_POINT.instantiate()
		ap.global_position = player_controller.global_position + Vector2(0,-100)
		get_tree().current_scene.add_child(ap)
		#print(ap, ap.global_position, machine.player_controller.global_position)
		
	if event.is_action_pressed("debug_sprint"):
		sprint_pressed.emit(true)
	if event.is_action_released("debug_sprint"):
		sprint_released.emit(false)

	if event.is_action_pressed("interact"):
		#print("pressing interact")
		interact()

	if event.is_action_pressed("toggle_flashlight"):
		if current_state == scouting_state:
			scouting_state.scout_flashlight.toggle_flashlight()
		else:
			flash_light.toggle_flashlight()

func take_damage(damage: int) -> void:
	if not invulnerable_timer.is_stopped():
		return
	invulnerable_timer.start()
	change_health(-damage)
	
func change_health(amount: int) -> void:
	health += amount
	health = clampi(health, 0, max_health)
	if health <= 0:
		die()

func die():
	print("you are dead now")
	died.emit()

func interact() -> void:
	var interactables := interactables_in_reach.filter(func(interactable):
		return interactable.call("can_interact"))
	interactables.sort_custom(sort_by_distance)
	if not interactables.is_empty():
		for i in interactables:
			if i is Scout_Area2D:
				i.do_interaction()
				return
		var nearest_interactable = interactables.front()
		nearest_interactable.call("do_interaction")
		#print("nearest_interactable: ", nearest_interactable)

signal changing_anchor_point
func _is_interacting(node: Node2D):
	print("_is_interacting: ", node)
	if node is AnchorPoint:
		if grappling_state.current_anchor != null:
			grappling_state.current_anchor.detach(player_controller.global_position)
		grappling_state.current_anchor = node
		change_state(grappling_state)

	if node is RepairTarget:
		# TODO: switch to Repairing state to manage repair animations etc (if needed)
		#print("getting repair target")
		pass

	if node is RechargingStation:
		print("interacting with recharging station")
		scouting_state.recharge()
		flash_light.recharge()
		
func sort_by_distance(a: Node2D, b : Node2D) -> bool:
	var distance_a := self.global_position.distance_squared_to(a.global_position)
	var distance_b := self.global_position.distance_squared_to(b.global_position)
	return distance_a < distance_b

func add_interactable(interactable: Node2D) -> void:
	#print("add_interactable ", self)
	interactables_in_reach.append(interactable)

func remove_interactable(interactable: Node2D) -> void:
	#print("remove_interactable", self)
	interactables_in_reach.erase(interactable)

func _on_interacting_with_scout():
	print("INTERACT WITH SCOUT")
	scouting_state.mover.in_the_world = false
	scouting_state.scout.hide()
	scout_in_inventory = true
	scouting_state.mover.collider.disabled = true
	scouting_state.mover.scout_area2d.set_monitoring(false)
	#print("in world? ",  scouting_state.mover.in_the_world)
	if current_state == scouting_state:
		change_state(walking_state)
