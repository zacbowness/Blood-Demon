extends CanvasLayer

onready var health_bar_over = $Node2D/HealthBarOver
onready var update_tween = $Node2D/UpdateTween
onready var health_bar_under = $Node2D/HealthBarUnder

onready var blood_bar_over = $BloodBar/BloodBarOver
onready var update_tween2 = $BloodBar/UpdateTween
onready var blood_bar_under = $BloodBar/BloodBarUnder

onready var stamina_bar = $StaminaBar/StaminaBar

onready var Boss_health_bar_over = $BossHealthBar/HealthBarOver
onready var update_tween3 = $BossHealthBar/UpdateTween
onready var Boss_health_bar_under = $BossHealthBar/HealthBarUnder
const DIALOG = preload("res://Scenes/Dialogue.tscn")

func _on_Player_health_updated(health):
	health_bar_over.value = health
	update_tween.interpolate_property(health_bar_under, "value", health_bar_under.value, health, 0.9, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	update_tween.start()

func _on_Player_blood_gauge_updated(blood):
	blood_bar_over.value = blood
	update_tween2.interpolate_property(blood_bar_under, "value", blood_bar_under.value, blood, 0.9, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	update_tween2.start()

func _on_Player_stamina_updated(stamina):
	stamina_bar.value = stamina
	
func _on_Boss_health_updated(health):
	Boss_health_bar_over.value = health
	update_tween3.interpolate_property(Boss_health_bar_under, "value", Boss_health_bar_under.value, health, 0.9, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	update_tween3.start()

func _ready():
	var player = get_parent().get_node("Player")
	var boss = get_parent().get_node("Demon")
	
	health_bar_over.max_value = player.max_health
	health_bar_over.value = player.max_health
	health_bar_under.max_value = player.max_health
	health_bar_under.value = player.max_health
	
	stamina_bar.max_value = player.max_stamina
	stamina_bar.value = player.max_stamina
	
	blood_bar_over.max_value = player.max_blood
	blood_bar_over.value = player.blood_gauge
	blood_bar_under.max_value = player.max_blood
	blood_bar_under.value = player.blood_gauge
#
	if boss != null:
		Boss_health_bar_over.max_value = boss.health
		Boss_health_bar_over.value = boss.health
		Boss_health_bar_under.max_value = boss.health
		Boss_health_bar_under.value = boss.health
		$BossHealthBar/AnimationPlayer.get_animation("showBossHealthBar").track_set_key_value(2, 2, Boss_health_bar_under.max_value)

func _process(delta):
	blood_bar_over.modulate.g = clamp(40/blood_bar_over.value, 0, 1)
	blood_bar_over.modulate.b = clamp(40/blood_bar_over.value, 0, 1)
	blood_bar_under.modulate.g = clamp(40/blood_bar_over.value, 0, 1)
	blood_bar_under.modulate.b = clamp(40/blood_bar_over.value, 0, 1)
	
var amplitude = 0
var priority = 0

func Stamina_bar_shake(duration = 0.1, frequency = 100, amplitude = 4, priority = 0):
	if priority >= self.priority:
		self.priority = priority
		self.amplitude = amplitude
		
		$Duration.wait_time = duration
		$Frequency.wait_time = 1/ float(frequency)
		$Duration.start()
		$Frequency.start()
		
		_new_shake()

func _new_shake():
	var rand = $StaminaBar.position
	rand.x += rand_range(-amplitude, amplitude)
	rand.y += rand_range(-amplitude, amplitude)
	
	$StaminaBar/ShakeTween.interpolate_property($StaminaBar, "position", $StaminaBar.position, rand, $Frequency.wait_time, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$StaminaBar/ShakeTween.start()

func _reset():
	$StaminaBar/ShakeTween.interpolate_property($StaminaBar, "position", $StaminaBar.position, Vector2(32, 44), $Frequency.wait_time, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$StaminaBar/ShakeTween.start()
	
	priority = 0

func _on_Frequency_timeout():
	_new_shake()

func _on_Duration_timeout():
	_reset()
	$Frequency.stop()
	
func generate_dialog():
	var dialog = DIALOG.instance()
	add_child(dialog)
