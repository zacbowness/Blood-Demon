extends KinematicBody2D

const UP_Direction := Vector2.UP

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var speed := 500.0
export var jump_strength := 500.0
export var maximum_jumps := 2
export var double_jump_strength := 800.0
export var gravity := 4500.0

var _jumps_made := 0
var _velocity := Vector2.ZERO

##Code to preserve sprite when animating:
#onready var _pivot: Node2D = $PlayerSprite
#onready var _animation_player: AnimationPlayer = $PlayerSprite/AnimationPlayer
#onready var _start_scale: Vector2 = _pivot.scale

func _physics_process(delta:float) -> void:
	var _horizontal_direction = (
		Input.get_action_strength("move_right")
		 - Input.get_action_strength("move_left")
	)
	
	_velocity.x = (_horizontal_direction * speed)
	_velocity.y += (gravity*delta)
	
	
#Creating Variables to assign kinematic states:
	var is_falling := (_velocity.y > 0.0) and not (is_on_floor())
	var is_jumping := Input.is_action_just_pressed("jump") and is_on_floor()
	var is_double_jumping := Input.is_action_just_pressed("jump") and not is_on_floor()
	var is_jump_cancelled := Input.is_action_just_released("jump") and _velocity.y < 0.0
	var is_idling := is_on_floor() and is_zero_approx(_velocity.x)
	var is_running := is_on_floor() and not is_zero_approx(_velocity.x)
	
#Working with these kinematic states:
	if is_jumping:
		_jumps_made += 1
		_velocity.y = -jump_strength
		
	#Allows for double jump
	elif is_double_jumping:
		_jumps_made += 1
		if _jumps_made <= maximum_jumps:
			_velocity.y = -double_jump_strength

			
	#Allows players to cancel jump at any time
	elif is_jump_cancelled:
		_velocity.y = 0.0

	#Resets jump state
	elif is_idling or is_running:
		_jumps_made = 0

	
	_velocity = move_and_slide(_velocity, UP_Direction)
	
##	Flip player sprite according to side moving
#	if not is_zero_approx(_velocity.x):
#		_pivot.scale.x = sign(_velocity.x)*_start_scale.x
#
##	Play jump animation
#	if is_jumping or is_double_jumping:
#		_animation_player.play("jump")
#
##	Play falling animation
#	elif is_falling:
#		_animation_player.play("fall")
#
##		Play idle animation
#	elif is_idling:
#		_animation_player.play("idle")
