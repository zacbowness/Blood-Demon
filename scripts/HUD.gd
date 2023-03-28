extends CanvasLayer

onready var health_bar_over = $Node2D/HealthBarOver
onready var update_tween = $Node2D/UpdateTween
onready var health_bar_under = $Node2D/HealthBarUnder

onready var stamina_bar_over = $StaminaBar/StaminaBarOver
onready var update_tween2 = $StaminaBar/TweenStamina
onready var stamina_bar_under = $StaminaBar/StaminaBarUnder

func _on_Player_health_updated(health):
	health_bar_over.value = health
	update_tween.interpolate_property(health_bar_under, "value", health_bar_under.value, health, 0.9, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	update_tween.start()

func _on_Player_stamina_updated(stamina):
	stamina_bar_over.value = stamina

func _physics_process(delta):
	update_tween2.interpolate_property(stamina_bar_under, "value", stamina_bar_under.value, stamina_bar_over.value, 0.9, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	update_tween2.start()
