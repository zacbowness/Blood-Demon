extends KinematicBody2D

signal health_updated(health)
signal killed()
signal hitEnemy()

const invincibility_duration = 1.5
onready var hurtbox = $PlayerHurtbox
onready var blinker = $Blinker

const UP = Vector2(0, -1)
export var GRAVITY = 15*2
export var MAXFALLSPEED = 200*2
export var MAXSPEED = 80*2
export var SPRINTMOD = 2.0
export var JUMPFORCE = 200*2
export var ACCEL = 10*2
export var ATTACKPUSH = 150
export (float) var max_health = 1000
onready var health = max_health setget _set_health
onready var invulnerability_timer = $InvulnerabilityTimer

var isAlive = false
var isAttacking = false
var attackAlt = false
var facing_right = true
var motion = Vector2()

func _physics_process(delta):
	apply_gravity()
	
	update_movement()
	
	animate_sprite()
	
	motion = move_and_slide(motion, UP)

func update_movement():
#	// MOVE LEFT & RIGHT //
	if Input.is_action_pressed("move_right"):
		motion.x += ACCEL
		facing_right = true
		$Camera2D.offset_h = .55
	elif Input.is_action_pressed("move_left"):
		motion.x-= ACCEL
		facing_right = false
		$Camera2D.offset_h = -.55
	else:
		motion.x = lerp(motion.x, 0, 0.2)
	
#	// SPRINTING //
	if Input.is_action_pressed("sprint"):
		MAXSPEED = lerp(MAXSPEED, 180*SPRINTMOD, 0.5)
	else:
		MAXSPEED = lerp(MAXSPEED, 180, 0.1)

#	// MAXSPEED LIMIT //
	motion.x = clamp(motion.x, -MAXSPEED, MAXSPEED)

#	// JUMPING //
	if is_on_floor():
		if Input.is_action_pressed("jump"):
			motion.y = -JUMPFORCE
	
#	// ATTACK MOTION //
	if Input.is_action_just_pressed("attack"):
		motion.x += ATTACKPUSH*$AnimatedSprite.scale.x
	
#	// ATTACK AREA ENABLING //
	if ($AnimatedSprite.animation == "Attack"):
		if $AnimatedSprite.frame == 1 or $AnimatedSprite.frame == 2:
			$AttackArea/CollisionShape2D.disabled = false
			z_index = 1
		else:$AttackArea/CollisionShape2D.disabled = true
	elif $AnimatedSprite.animation == "Attack2":
		if $AnimatedSprite.frame == 2:
			$AttackArea/CollisionShape2D.disabled = false
			z_index = 1
		else:$AttackArea/CollisionShape2D.disabled = true
	else:
		z_index = 0

func apply_gravity():
	motion.y += GRAVITY
	if motion.y > MAXFALLSPEED:
		motion.y = MAXFALLSPEED

func animate_sprite():
#	// HANDLING ANIMATIONS //
	if not isAttacking:
	#	// MOVE LEFT & RIGHT //
		if Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left"):
			$AnimatedSprite.play("Run")
		else:
			$AnimatedSprite.play("Idle")
		
	#	// JUMPING //	
		if not is_on_floor():
			if motion.y < 0:
				$AnimatedSprite.play("Jump")
			elif motion.y > 5 and motion.y < 55:
				$AnimatedSprite.play("Fall_transition")
			else:
				$AnimatedSprite.play("Fall")
		
	#	// SPRINTING //
		if Input.is_action_pressed("sprint"):
			$AnimatedSprite.speed_scale = abs(motion.x/200)
		else:
			$AnimatedSprite.speed_scale = 1

	#	// TURN AROUND ANIM //
		var direction = (Input.get_action_strength("move_right") - Input.get_action_strength("move_left"))
		if ((motion.x > 140 and direction <0) or (motion.x < -140 and direction >0)):
			facing_right = !facing_right
			if is_on_floor():
				$AnimatedSprite.play("Turn Around")
	
#	// FLIP SPRITE & HITBOXES //
	if facing_right:
		$AnimatedSprite.scale.x = 1
		$HitBox.position.x = 0
		$PlayerHurtbox.position.x = 0
		$AttackArea/CollisionShape2D.position.x = 40
	else:
		$AnimatedSprite.scale.x = -1
		$HitBox.position.x = 10
		$PlayerHurtbox.position.x = 10
		$AttackArea/CollisionShape2D.position.x = -30

#	// ATTACK ANIM //
	if Input.is_action_just_pressed("attack"):
		$AnimatedSprite.speed_scale = 1
		if not attackAlt:
			$AnimatedSprite.play("Attack")
		else:
			$AnimatedSprite.play("Attack2")
		isAttacking = true;
		attackAlt = not attackAlt

func _on_AnimatedSprite_animation_finished():
#	// STOP ATTACK STATE //
	if $AnimatedSprite.animation == "Attack" or $AnimatedSprite.animation == "Attack2":
		$AttackArea/CollisionShape2D.disabled = true
		isAttacking = false;

func damage (amount):
	if invulnerability_timer.is_stopped():
		invulnerability_timer.start()
		_set_health(health - amount)

#Stops player from getting hit or moving when dead
func die():
	set_physics_process(false)
	$AnimatedSprite.play("Death") 
	apply_gravity()
	$PlayerHurtbox/CollisionShape2D.disabled = true
		
#Updates the players health
func _set_health(value):
	var prev_health = health
	health = clamp (value,0, max_health)
	if health != prev_health:
		emit_signal("health_updated", health)
		print (health) 
		if health == 0:
			die()
			emit_signal("killed")

#func _on_PlayerHurtbox_area_entered(area):
#
#	takeDamage()

#Function called when player is hit
func takeDamage(damage):
	_set_health(health - damage)
#	blinker.start_blinking(self,invincibility_duration)
#	hurtbox.start_invincibility(invincibility_duration)	
	


func _on_AttackArea_body_entered(body):
	if "Skeleton" in body.name:
		body.death()
	elif "Goblin" in body.name:
		body.death()

func _on_Enemy_hit(damage, dir_right):
	takeDamage(damage)
	if dir_right:
		motion = Vector2(500, -150)
	else:
		motion = Vector2(-500, -150)
	MAXSPEED = 500
