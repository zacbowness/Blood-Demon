extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$AudioStreamPlayer.play()
	$HUD/BossHealthBar/AnimationPlayer.play("showBossHealthBar")


func reset_enemies():
	pass


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Fade_in":
		get_tree().change_scene("res://Scenes/Outro.tscn")
