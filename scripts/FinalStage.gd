extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	$AudioStreamPlayer.play()
	$HUD/BossHealthBar/AnimationPlayer.play("showBossHealthBar")
	$Transition/AnimationPlayer.play("Fade_out")


func reset_enemies():
	get_tree().reload_current_scene()

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Fade_in":
		get_tree().change_scene("res://Scenes/Outro.tscn")
