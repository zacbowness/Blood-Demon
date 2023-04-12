extends Node2D

var kill = false

func _ready():
	$AudioStreamPlayer.play()
	$HUD/BossHealthBar/AnimationPlayer.play("showBossHealthBar")
	$Transition/AnimationPlayer.play("Fade_out")
	
func _physics_process(delta):
	if kill == false:
		outro()

func reset_enemies():
	get_tree().reload_current_scene()

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Fade_in":
		get_tree().change_scene("res://Scenes/Outro.tscn")

func outro():
	if $Demon.isDead == true:
		kill = true
		$Transition/AnimationPlayer.play(("Fade_in"))
