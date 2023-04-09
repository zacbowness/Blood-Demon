extends Node2D

onready var animation_player = $KinematicBody2D/AnimationPlayer
onready var timer = $KinematicBody2D/ResetTimer
onready var reset_position = global_position

export var GRAVITY = 30
export var reset_time : float = 1.0 

var velocity = Vector2()
var is_triggered = false


func _ready():
	set_physics_process(false)
	
func _physics_process(delta):
	velocity.y += GRAVITY * delta
	position += velocity

func collide_with(collision: KinematicCollision2D, collider: KinematicBody2D):
	if ! is_triggered:
		is_triggered = true
		animation_player.play("Shake")
		velocity = Vector2.ZERO
		
func _on_AnimationPlayer_animation_finished(anim_name):
	set_physics_process(true)
	timer.start(reset_time)


func _on_Timer_timeout():
	set_physics_process(false)
	yield(get_tree(), "physics_frame")
	#var temp = collision_layer
	#collision_layer = 0
	global_position = reset_position
