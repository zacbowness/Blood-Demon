extends KinematicBody2D

const UP = Vector2(0, -1)
const GRAVITY = 15*2
const MAXFALLSPEED = 200*2
const MAXSPEED = 80*2
const JUMPFORCE = 200*2
const ACCEL = 10*2

var facing_right = true
var motion = Vector2()

func _physics_process(delta):
	
	motion.y += GRAVITY
	if motion.y > MAXFALLSPEED:
		motion.y = MAXFALLSPEED
	
	motion.x = clamp(motion.x, -MAXSPEED, MAXSPEED)
	
	if Input.is_action_pressed("move_right"):
		motion.x += ACCEL
		$Camera2D.offset_h = .55
		$AnimatedSprite.play("Run")
		$AnimatedSprite.scale.x = 1
		$CollisionShape2D.position.x = 0
	elif Input.is_action_pressed("move_left"):
		motion.x -= ACCEL
		$Camera2D.offset_h = -.55
		$AnimatedSprite.play("Run")
		$AnimatedSprite.scale.x = -1
		$CollisionShape2D.position.x = 10
	else:
		motion.x = lerp(motion.x, 0, 0.2)
		$AnimatedSprite.play("Idle")
	
	
	
	if is_on_floor():
		if Input.is_action_pressed("jump"):
			motion.y = -JUMPFORCE
	else:
		if motion.y < 0:
			$AnimatedSprite.play("Jump")
		elif motion.y < -10 and motion.y > 10:
			$AnimatedSprite.play("Fall_transition")
		else:
			$AnimatedSprite.play("Fall")
	
	motion = move_and_slide(motion, UP)

func turn_around():
	$AnimatedSprite.play("Turn Around")
	print(1)
	facing_right = not facing_right
	$AnimatedSprite.flip_h = not $AnimatedSprite.flip_h
