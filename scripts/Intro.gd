extends Node2D

export var mainGameScene : PackedScene
# Called when the node enters the scene tree for the first time.
func _ready():
	$RichTextLabel/AnimationPlayer.play("Intro")

func _show_Buttons():
	$YesButton.disabled = false
	$NoButton.disabled = false
	$SkipButton.disabled = true

func _on_YesButton_pressed():
	$YesButton.disabled = true
	$NoButton.disabled = true
	$RichTextLabel/AnimationPlayer.play("Continue")

func _on_NoButton_pressed():
	$YesButton.disabled = true
	$NoButton.disabled = true
	$RichTextLabel/AnimationPlayer.play("Quit")

func quit():
	get_tree().change_scene("res://Scenes/Menu.tscn")

func continue_to_game():
	get_tree().change_scene(mainGameScene.resource_path)

func _on_SkipButton_pressed():
	continue_to_game()
