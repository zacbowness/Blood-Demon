extends CanvasLayer

onready var health_bar_over = $Node2D/HealthBarOver
onready var update_tween = $Node2D/UpdateTween
onready var health_bar_under = $Node2D/HealthBarUnder

onready var blood_bar_over = $BloodBar/BloodBarOver
onready var update_tween2 = $BloodBar/UpdateTween
onready var blood_bar_under = $BloodBar/BloodBarUnder

onready var stamina_bar_over = $StaminaBar/StaminaBarOver

func _on_Player_health_updated(health):
	health_bar_over.value = health
	update_tween.interpolate_property(health_bar_under, "value", health_bar_under.value, health, 0.9, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	update_tween.start()

func _on_Player_blood_gauge_updated(blood):
	blood_bar_over.value = blood
	update_tween2.interpolate_property(blood_bar_under, "value", blood_bar_under.value, blood, 0.9, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	update_tween2.start()

func _on_Player_stamina_updated(stamina):
	stamina_bar_over.value = stamina

func _ready():
	var player = get_tree().get_nodes_in_group("Player")[0]
	health_bar_over.max_value = player.max_health
	health_bar_over.value = player.max_health
	health_bar_under.max_value = player.max_health
	health_bar_under.value = player.max_health
	
	stamina_bar_over.max_value = player.max_stamina
	stamina_bar_over.value = player.max_stamina
	
	blood_bar_over.max_value = player.max_blood
	blood_bar_over.value = player.blood_gauge
	blood_bar_under.max_value = player.max_blood
	blood_bar_under.value = player.blood_gauge
