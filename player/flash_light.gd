class_name FlashLight 
extends PointLight2D

signal turned_on
signal turned_off
signal battery_loaded
signal battery_empty


@export var max_battery : float
@export var battery_drain_per_second : float

var battery := 0.0


func _ready() -> void:
	battery = max_battery
	

func _process(delta: float) -> void:
	if enabled:
		self.look_at(get_global_mouse_position())
		_do_drain_battery(delta)


func _do_drain_battery(delta: float) -> void:
	battery -= battery_drain_per_second * delta
	battery = maxf(battery, 0.0)
	
	if is_empty_battery():
		switch_off()
		battery_empty.emit()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_flashlight"):
		toggle_flashlight()


func recharge():
	battery = max_battery

func toggle_flashlight() -> void:
	if enabled:
		switch_off()
	else:
		switch_on()

func switch_off() -> void:
	if self.enabled:
		self.enabled = false
		turned_off.emit()

func switch_on() -> void:
	if not self.enabled and not is_empty_battery():
		self.enabled = true
		turned_on.emit()


func is_empty_battery() -> bool:
	return is_zero_approx(battery)

func load_battery(amount: float) -> void:
	battery += amount
	battery = clampf(battery, 0.0, max_battery)
	battery_loaded.emit()
