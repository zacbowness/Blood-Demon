extends KinematicBody2D

var is_moving_right = true 

var gravity = 9.8
var velocity = Vector2(0,0)
var speed = -30
var isAttacking = false;
var animation = false;
var inRange = false 

func _ready():
	$AnimationPlayer.play("Walk")

func _process(delta):
	print(isAttacking)
	if (isAttacking != true && inRange == false && $AnimationPlayer.current_animation != "Attack"):
		move_character()
		detect_turn_around()
	if ($AnimationPlayer.current_animation == "Attack"):
		return	
	
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
		
func _on_PlayerDetector_body_entered(body):
	$AnimationPlayer.play("Attack")
	inRange = true 

func hit():
	$HitBox.monitoring = true 

func end_of_hit():
	$HitBox.monitoring = false  

func _on_PlayerDetector_body_exited(body):
	inRange = false 

func _on_AnimationPlayer_animation_finished(anim_name):
	if (anim_name == "Attack"):
		if (inRange):
			$AnimationPlayer.play("Attack")
		else:
			isAttacking = false 
			$AnimationPlayer.play("Walk")
		
		