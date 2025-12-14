class_name Player
extends CharacterBody2D

signal health_changed
signal died
signal stamina_depleted

@export_category("Player Survival Stats")
@export var max_health : int
@export var max_stamina : float
@export var stamina_drain_per_second : float
@export var stamina_recover_per_second : float

# for collision impact damage
@export var min_impact_speed : float
@export var max_impact_speed : float

@export_category("Player Movement")
@export var speed : float
@export var jump_velocity : float
@export var acceleration : float
@export var deceleration : float

@onready var invulnerable_timer: Timer = $InvulnerableTimer
@onready var grapple_control: GrappleControl = $GrappleControl
@onready var flash_light: FlashLight = $FlashLight2D

var health := 100
var stamina := 100.0
var last_velocity := Vector2.ZERO
var interactables_in_reach: Array[Node2D] = []


func _ready() -> void:
	health = max_health
	stamina = max_stamina


func _physics_process(delta: float) -> void:
	last_velocity = self.velocity
	if not is_on_floor():
		velocity += get_gravity() * delta	# apply gravity
	
	if Input.is_action_just_pressed("jump") and (is_on_floor() or grapple_control.launched):
		velocity.y += jump_velocity
		grapple_control.retract()
	if Input.is_action_just_pressed("interact"):
		interact()
	
	_update_horizontal_velocity()
	_update_stamina(delta)
	if move_and_slide():
		_handle_collision()


func _update_horizontal_velocity() -> void:
	var direction := Input.get_axis("move_left", "move_right")
	if is_zero_approx(direction):
		velocity.x = lerpf(velocity.x, 0.0, deceleration)
	else:
		velocity.x = lerpf(velocity.x, direction * speed, acceleration)


func _update_stamina(delta: float) -> void:
	if grapple_control.launched:
		stamina -= stamina_drain_per_second * delta
	elif is_on_floor():
		stamina += stamina_recover_per_second * delta
	stamina = clampf(stamina, 0.0, max_stamina)
	if is_zero_approx(stamina):
		stamina_depleted.emit()


func _handle_collision() -> void:
	var collision := get_slide_collision(0)
	var collision_damage := calculate_collision_damage(collision)
	if collision_damage > 0:
		change_health(-collision_damage)


func calculate_collision_damage(collision: KinematicCollision2D) -> int:
	# impact_speed is the speed at which the character hits the surface, 
	# measured along the direction pointing into the collider.
	var impact_speed := -last_velocity.dot(collision.get_normal())
	if impact_speed < min_impact_speed:
		return 0
	
	var t := inverse_lerp(min_impact_speed, max_impact_speed, impact_speed)
	t = clampf(t, 0.0, 1.0)
	var damage := lerpf(5.0, max_health, t * t)
	#print("impact_speed ", impact_speed, " calculate_collision_damage ", damage)
	return roundi(damage)


func interact() -> void:
	if interactables_in_reach.is_empty():
		return
	interactables_in_reach.sort_custom(sort_by_distance)
	var nearest_interactable = interactables_in_reach.front()
	nearest_interactable.call("do_interaction")

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


func take_damage(damage_amount: int) -> void:
	if not invulnerable_timer.is_stopped():
		return
	print("take_damage ", damage_amount)
	invulnerable_timer.start()
	change_health(-damage_amount)


func change_health(amount : int) -> void:
	health += amount
	health = clampi(health, 0, max_health)
	health_changed.emit()
	if health <= 0:
		die()


func die():
	print("your are dead now")
	died.emit()
