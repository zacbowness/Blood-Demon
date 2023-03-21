extends KinematicBody2D

const UP = Vector2(0, -1)
export var GRAVITY = 15*2
export var MAXFALLSPEED = 200*2
export var MAXSPEED = 80*2
export var SPRINTMOD = 2.0
export var JUMPFORCE = 200*2
export var ACCEL = 10*2
export var ATTACKPUSH = 30


var isSprinting = false
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
#		Check if sprinting:
		if Input.is_action_pressed("move_right") and Input.is_action_just_pressed("sprint"):
			MAXSPEED = SPRINTMOD*MAXSPEED
			motion.x += ACCEL
			$Camera2D.offset_h = .55
		if Input.is_action_just_released("sprint"):
			MAXSPEED = MAXSPEED/SPRINTMOD
		else:
			motion.x += ACCEL
			$Camera2D.offset_h = .55
	elif Input.is_action_pressed("move_left"):
#		Check if sprinting:
		if Input.is_action_pressed("move_left") and Input.is_action_just_pressed("sprint"):
			MAXSPEED = SPRINTMOD*MAXSPEED
			motion.x -= ACCEL
		if Input.is_action_just_released("sprint"):
			MAXSPEED = MAXSPEED/SPRINTMOD
			$Camera2D.offset_h = -.55
		else:
			motion.x-= ACCEL
			$Camera2D.offset_h = -.55
	else:
		motion.x = lerp(motion.x, 0, 0.2)
	
	if is_on_floor():
		if Input.is_action_pressed("jump"):
			motion.y = -JUMPFORCE
	
	if Input.is_action_pressed("attack"):
		motion.x += ATTACKPUSH*$AnimatedSprite.scale.x


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
