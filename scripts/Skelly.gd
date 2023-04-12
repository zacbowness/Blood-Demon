extends Area2D

signal dialog
var can_interact = false
const DIALOG = preload("res://Scenes/Dialogue.tscn")


func _physics_process(delta):
	$SkellyBody/Sprite/AnimationPlayer.play("Idle")

func _ready():
	connect("dialog",get_tree().get_nodes_in_group("HUD")[0],"generate_dialog") 

func _on_Area2D_body_exited(body):
	if body.name == "Player":
		$Key.visible = false
		can_interact = false

func _on_Area2D_body_entered(body):
	if body.name == "Player":
		$Key.visible = true
		can_interact = true

func _input (event):
	if Input.is_key_pressed(KEY_E) and can_interact == true:
		$Key.visible = false
		emit_signal("dialog")
