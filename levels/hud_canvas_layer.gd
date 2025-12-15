class_name Hud extends CanvasLayer

@onready var health_progress_bar: ProgressBar = %HealthProgressBar
@onready var stamina_progress_bar: ProgressBar = %StaminaProgressBar
@onready var flashlight_progress_bar: ProgressBar = %FlashlightProgressBar

func set_health(value: float) -> void:
	health_progress_bar.value = value

func set_stamina(value: float) -> void:
	stamina_progress_bar.value = value

func set_flashlight(value: float) -> void:
	flashlight_progress_bar.value = value
