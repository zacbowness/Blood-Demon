extends KinematicBody2D

var is_moving_right = true 

var gravity = 9.8
var velocity = Vector2(0,0)

var speed = -30

func _process(delta):
	move_character()
	detect_turn_around()
	
func move_character():
	velocity.x = -speed if is_moving_right else speed
	velocity.y += gravity
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
func detect_turn_around():
	if not $RayCast2D.is_colliding() and is_on_floor():
		is_moving_right = !is_moving_right
		scale.x = -scale.x

func _on_WallDetector_body_entered(body):
	is_moving_right = !is_moving_right
	scale.x = -scale.x
		
func hit():
	$HitBox.monitoring = true
	
func end_of_hit():
	$HitBox.monitoring = true 



	
