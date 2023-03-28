extends KinematicBody2D

signal health_updated(health)
signal stamina_updated(stamina)
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
export var ATTACKPUSH = 70
export (float) var max_health = 1000
onready var health = max_health setget _set_health
export (float) var max_stamina = 100
onready var stamina = max_stamina setget _set_stamina

var isAlive = true
var isAttacking = false
var attackAlt = false
var isSprinting = false
var isMoving = false
var facing_right = true
var motion = Vector2()
var controllable
var playerDamage = 100

func _ready():
	connect("health_updated", get_tree().get_nodes_in_group("HUD")[0], "_on_Player_health_updated")
	connect("stamina_updated", get_tree().get_nodes_in_group("HUD")[0], "_on_Player_stamina_updated")

func _physics_process(delta):
	controllable = (isAlive and !isAttacking) and $StunTimer.is_stopped()
	
#	// MAXSPEED LIMIT //
	motion.x = clamp(motion.x, -MAXSPEED, MAXSPEED)	
	apply_gravity()
	
	update_movement()
	
#	// RESET MAXSPEED IF CHANGED //
	if isAlive:MAXSPEED = lerp(MAXSPEED, 180, 0.1)
	else:MAXSPEED = lerp(MAXSPEED, 0, 0.1)
	
	animate_sprite()

	motion = move_and_slide(motion, UP)

func update_movement():
	if controllable:
	#	// MOVE LEFT & RIGHT //
		if Input.is_action_pressed("move_right"):
			motion.x += ACCEL
			facing_right = true
			isMoving = true
			$Camera2D.offset_h = .55
		elif Input.is_action_pressed("move_left"):
			motion.x-= ACCEL
			facing_right = false
			isMoving = true
			$Camera2D.offset_h = -.55
		else:
			motion.x = lerp(motion.x, 0, 0.2)
			isMoving = false
		
	#	// SPRINTING //
		if Input.is_action_pressed("sprint") and stamina >0 and isMoving:
			MAXSPEED = lerp(MAXSPEED, 180*SPRINTMOD, 0.5)
			isSprinting = true
		else:
			isSprinting = false
	
	#	// JUMPING //
		if is_on_floor():
			if Input.is_action_pressed("jump") and stamina>30:
				motion.y = -JUMPFORCE
		
	#	// ATTACK MOTION //
		if Input.is_action_just_pressed("attack") and stamina>20:
			motion.x += ATTACKPUSH*$AnimatedSprite.scale.x
			MAXSPEED = 180
			motion.x = clamp(motion.x, -MAXSPEED, MAXSPEED)
	
	
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
	
#	// REGEN STAMINA //
	if $StaminaRegenBuffer.is_stopped():
		_set_stamina(stamina+.75)

func apply_gravity():
	motion.y += GRAVITY
	if motion.y > MAXFALLSPEED:
		motion.y = MAXFALLSPEED

func animate_sprite():
#	// HANDLING ANIMATIONS //
	if controllable:
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
		if Input.is_action_pressed("sprint") and isMoving:
			$AnimatedSprite.speed_scale = abs(motion.x/200)
			_set_stamina(stamina - .8);$StaminaRegenBuffer.start()
		else:
			$AnimatedSprite.speed_scale = 1

	#	// TURN AROUND ANIM //
		var direction = (Input.get_action_strength("move_right") - Input.get_action_strength("move_left"))
		if ((motion.x > 140 and direction <0) or (motion.x < -140 and direction >0)):
			facing_right = !facing_right
			if is_on_floor():
				$AnimatedSprite.play("Turn Around")
	
#	// FLIP SPRITE & HITBOXES //
	if isAlive:
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
	if Input.is_action_just_pressed("attack") and stamina>25 and $StunTimer.is_stopped():
		_set_stamina(stamina-25);$StaminaRegenBuffer.start()
		$AnimatedSprite.speed_scale = 1;print(2)
		if not attackAlt:
			$AnimatedSprite.play("Attack")
		else:
			$AnimatedSprite.play("Attack2")
		isAttacking = true
		attackAlt = !attackAlt

func _on_AnimatedSprite_animation_finished():
#	// STOP ATTACK STATE //
	if $AnimatedSprite.animation == "Attack" or $AnimatedSprite.animation == "Attack2":
		$AttackArea/CollisionShape2D.disabled = true
		isAttacking = false;
		attackAlt = !attackAlt
	if $AnimatedSprite.animation == "Hit":
		isAttacking = false

#Stops player from getting hit or moving when dead
func die():
	isAlive = false
	$AnimatedSprite.play("Death") 
	apply_gravity()
	$PlayerHurtbox/CollisionShape2D.disabled = true
	if facing_right:
		$HitBox.position.x = -23
	else:
		$HitBox.position.x = 30
	$HitBox.position.y = 32
	$HitBox.shape.radius = 6
	$HitBox.shape.height = 30
	$HitBox.rotation_degrees = 90
#Updates the players health
func _set_health(value):
	var prev_health = health
	health = clamp (value,0, max_health)
	if health != prev_health:
		emit_signal("health_updated", health)
		if health == 0:
			die()
			emit_signal("killed")
	return health

#Updates the players stamina
func _set_stamina(value):
	var prev_stamina = stamina
	stamina = clamp (value,0, max_stamina)
	if stamina != prev_stamina:
		emit_signal("stamina_updated", stamina)

#Makes player invincible for certain amount of time
func takeDamage(damage):
	$StunTimer.start()
	$AnimatedSprite.play("Hit")
	var current_health = _set_health(health - damage)
	if current_health > clamp (0,0,max_health):
		hurtbox.player_hit(true)
		blinker.start_blinking(self,invincibility_duration)
		hurtbox.start_invincibility(invincibility_duration)	

func _on_AttackArea_body_entered(body):
	if body in get_tree().get_nodes_in_group("Enemy"):
		body.health = (body.health - playerDamage)
		if (body.health <= 0):
			body.death()

func _on_Enemy_hit(damage, dir_right):
	if $Blinker/BlinkTimer.is_stopped() and isAlive:
		takeDamage(damage)
		apply_knockback(dir_right)

func _on_PlayerHurtbox_area_entered(area):
	var body = area.get_parent()
	if body in get_tree().get_nodes_in_group("Enemy"):
		if (body.isDead == false):
			takeDamage(body.damage)
			apply_knockback(position.x > body.position.x)
	if body in get_tree().get_nodes_in_group("Trap"):
		takeDamage(1000)
	
func apply_knockback(direction):
	if direction:
		motion = Vector2(200, -150)
	else:
		motion = Vector2(-200, -150)
	MAXSPEED = 200
	facing_right = !direction
