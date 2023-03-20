extends KinematicBody2D

const UP = Vector2(0, -1)
const GRAVITY = 15*2
const MAXFALLSPEED = 200*2
const MAXSPEED = 80*2
const JUMPFORCE = 200*2
const ACCEL = 10*2

var isAttacking = false
var attackAlt = false
var motion = Vector2()

func _physics_process(delta):
	apply_gravity()
	
	motion.x = clamp(motion.x, -MAXSPEED, MAXSPEED)
	update_movement()
	
	animate_sprite()
	
	motion = move_and_slide(motion, UP)

func update_movement():
	if Input.is_action_pressed("move_right"):
		motion.x += ACCEL
		$Camera2D.offset_h = .55
	elif Input.is_action_pressed("move_left"):
		motion.x -= ACCEL
		$Camera2D.offset_h = -.55
	else:
		motion.x = lerp(motion.x, 0, 0.2)
	
	if is_on_floor():
		if Input.is_action_pressed("jump"):
			motion.y = -JUMPFORCE
	
	if Input.is_action_pressed("attack"):
		motion.x += 30*$AnimatedSprite.scale.x

func apply_gravity():
	motion.y += GRAVITY
	if motion.y > MAXFALLSPEED:
		motion.y = MAXFALLSPEED

func animate_sprite():

	if not isAttacking:
		if Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left"):
			$AnimatedSprite.play("Run")
		else:
			$AnimatedSprite.play("Idle")
		
		if not is_on_floor():
			if motion.y < 0:
				$AnimatedSprite.play("Jump")
			elif motion.y > 5 and motion.y < 55:
				$AnimatedSprite.play("Fall_transition")
			else:
				$AnimatedSprite.play("Fall")
		
		var direction = (Input.get_action_strength("move_right") - Input.get_action_strength("move_left"))
		if (motion.x > 0 and direction <0) or (motion.x < 0 and direction >0):
			$AnimatedSprite.play("Turn Around")
	
	if motion.x > 0:
		$AnimatedSprite.scale.x = 1
		$HitBox.position.x = 0
		$AttackArea/CollisionShape2D.position.x = 44.5
	elif motion.x < 0:
		$AnimatedSprite.scale.x = -1
		$HitBox.position.x = 10
		$AttackArea/CollisionShape2D.position.x = -44.5

	if Input.is_action_just_pressed("attack"):
		if not attackAlt:
			$AnimatedSprite.play("Attack")
		else:
			$AnimatedSprite.play("Attack2")
		isAttacking = true;
		attackAlt = not attackAlt
		$AttackArea/CollisionShape2D.disabled = false

func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "Attack" or $AnimatedSprite.animation == "Attack2":
		$AttackArea/CollisionShape2D.disabled = true
		isAttacking = false;
