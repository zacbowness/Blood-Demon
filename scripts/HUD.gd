extends CanvasLayer

onready var health_bar = $Node2D/HealthBar

func _on_Player_health_updated(health):
		health_bar.value = health
