extends KinematicBody2D

signal health_updated(health)
signal stamina_updated(stamina)
signal blood_gauge_updated(blood)
signal killed()
signal hitEnemy()

const invincibility_duration = 1.5
onready var hurtbox = $PlayerHurtbox
onready var blinker = $Blinker

const BloodBall = preload("res://Scenes/BloodBall.tscn")
const UP = Vector2(0, -1)
export var GRAVITY = 15*2
export var MAXFALLSPEED = 250*2
export var MAXSPEED = 100*2
export var SPRINTMOD = 2.0
export var JUMPFORCE = 290*2
export var ACCEL = 10*2
export var ATTACKPUSH = 30
export var ROLLPUSH = 250
export (float) var max_health = 250
export (float) var max_stamina = 100
export (float) var max_blood = 100

onready var health = max_health setget _set_health
onready var stamina = max_stamina setget _set_stamina
onready var blood_gauge = 100
onready var HUD = get_parent().get_node("HUD")

var isAlive = true
var isAttacking = false
var isRangeAttacking = false
var isRolling = false
var isCrouching = false
var attackAlt = false
var isSprinting = false
var isMoving = false
var facing_right = true
var isTurning = false
var motion = Vector2()
var controllable
var direction
var playerDamage = 100
var underSomething
var spawnPosition = position
var isPoisoned = false 
var current_health

func _ready():
	connect("health_updated", HUD, "_on_Player_health_updated")
	connect("stamina_updated", HUD, "_on_Player_stamina_updated")
	connect("blood_gauge_updated", HUD, "_on_Player_blood_gauge_updated")
	spawnPosition = position

func _physics_process(delta):
	
	apply_gravity()
	update_movement()
	animate_sprite()

func update_movement():
	controllable = (isAlive and !isAttacking and !isRangeAttacking and $StunTimer.is_stopped() and !isRolling)
	direction = (Input.get_action_strength("move_right") - Input.get_action_strength("move_left"))
	if controllable:
	#	// MOVE LEFT & RIGHT //
		if Input.is_action_pressed("move_right"):
			motion.x += ACCEL
			facing_right = true
			isMoving = true
		elif Input.is_action_pressed("move_left"):
			motion.x-= ACCEL
			facing_right = false
			isMoving = true
		else:
			motion.x = lerp(motion.x, 0, 0.2)
			isMoving = false
		
	#	// SPRINTING //
		if (Input.is_action_pressed("sprint") and isMoving) && !isCrouching:
			_set_stamina(stamina - .8);$StaminaRegenBuffer.start()
			if stamina > 0:isSprinting = true
			else:isSprinting = false
		else:
			isSprinting = false
	
	#	// JUMPING //
		if is_on_floor() && !isCrouching:
			if Input.is_action_pressed("jump"):
				motion.y = -JUMPFORCE;isTurning=false
				$Jump.play()
		
	#	// TURN AROUND //
		if ((motion.x > 140 and direction <0) or (motion.x < -140 and direction >0)) && !isTurning:
			if is_on_floor() && !isCrouching:
				isTurning = true
		
#		// CROUCHING //
		if Input.is_action_pressed("down"):
			isCrouching = true;
			$RayCast2D.enabled = true
		elif not underSomething: 
			isCrouching = false;
			$RayCast2D.enabled = false
		
		if $RayCast2D.is_colliding():
			underSomething = true
		else:underSomething = false
		
#	// ATTACK MOTION //
	if Input.is_action_just_pressed("attack") && $StunTimer.is_stopped() && !isRangeAttacking && !isRolling && isAlive:
		if stamina>20:
			_set_stamina(stamina-20);$StaminaRegenBuffer.start()
			motion.x += ATTACKPUSH*$AnimatedSprite.scale.x
			isAttacking = true;isCrouching = false
			attackAlt = !attackAlt
			$Attack.play()
		else:
			HUD.Stamina_bar_shake()
#	// RANGE ATTACK //
	if Input.is_action_just_pressed("right-click") && blood_gauge>20 && !isTurning && $StunTimer.is_stopped() && !isRangeAttacking && !isAttacking && isAlive:
		isRangeAttacking = true;isCrouching = false
		var fireattack = BloodBall.instance()
		_set_blood(blood_gauge-20)
		if (facing_right == true):
			fireattack.set_bloodball_direction(1)
		else:
			fireattack.set_bloodball_direction(-1)					
		get_parent().add_child(fireattack)
		fireattack.global_position = $BloodballPlacer.global_position
		
#	// I FRAME ROLL //
	if Input.is_action_just_pressed("roll") && isMoving && $StunTimer.is_stopped() && !isAttacking && isAlive:
		if stamina > 30 && !isRolling:
			_set_stamina(stamina-35);$StaminaRegenBuffer.start()
			isRolling = true
			motion.x += ROLLPUSH*$AnimatedSprite.scale.x
			$Roll.play()
		else:
			HUD.Stamina_bar_shake()

	
#	// REGEN STAMINA //
	if $StaminaRegenBuffer.is_stopped():_set_stamina(stamina+.75)
	
#	// MAXSPEED LIMIT //
	MAXSPEED = setMaxSpeed()
	motion.x = clamp(motion.x, -MAXSPEED, MAXSPEED)
	motion = move_and_slide(motion, UP)

func apply_gravity():
	motion.y += GRAVITY
	if motion.y > MAXFALLSPEED:
		motion.y = MAXFALLSPEED

func animate_sprite():
#	// HANDLING ANIMATIONS //
	if controllable:
	#	// MOVE LEFT & RIGHT //
		if !isTurning && !isCrouching:
			if isMoving:
				$AnimatedSprite.play("Run")
			else:
				$AnimatedSprite.play("Idle")
		
	#	// JUMPING //
		if !is_on_floor() && !isCrouching:
			if motion.y < 0:
				$AnimatedSprite.play("Jump")
			elif motion.y > -55 and motion.y < 55:
				$AnimatedSprite.play("Fall_transition")
			else:
				$AnimatedSprite.play("Fall")
		
	#	// SPRINTING //
		if isSprinting:
			$AnimatedSprite.speed_scale = abs(motion.x/200)
		else:
			$AnimatedSprite.speed_scale = 1

	#	// TURN AROUND ANIM //
		if isTurning:
			if direction == -1: facing_right = true;else:facing_right=false
			$AnimatedSprite.play("Turn Around");$AnimatedSprite.speed_scale =1
		
		if isCrouching:
			if isMoving:$AnimatedSprite.play("Crouch Walk")
			else:$AnimatedSprite.play("Crouching")
			if Input.is_action_just_pressed("down"):
				$AnimatedSprite.play("Crouch Transi")
		if Input.is_action_just_released("down") && is_on_floor():
			$AnimatedSprite.play("Crouch Transi")
		
#	// ATTACK ANIM //
	if isAttacking:
		$AnimatedSprite.speed_scale = 1
		if not attackAlt:$AnimatedSprite.play("Attack")
		else:$AnimatedSprite.play("Attack2")
		
	if isRangeAttacking:
		$AnimatedSprite.speed_scale = 1
		$AnimatedSprite.play("Range Attack")
		
#	// I FRAME ROLL //
	if isRolling:
		$AnimatedSprite.play("Roll")
		
#	// FLIP SPRITE & HITBOXES //
	if isAlive:
		$HitBox.shape.radius = 8
		$HitBox.shape.height = 22
		$HitBox.rotation_degrees = 0
		$HitBox.position.y = 21
		$HitBox.position.x = 0
		if isCrouching:
			$HitBox.position.y = 26
			$HitBox.shape.height = 11
			$PlayerHurtbox/CollisionShape2D.position.y = 5
			$PlayerHurtbox/CollisionShape2D.shape.extents.y = 13.5
		else:
			$HitBox.position.y = 21
			$HitBox.shape.height = 22
			$PlayerHurtbox/CollisionShape2D.position.y = 0
			$PlayerHurtbox/CollisionShape2D.shape.extents.y = 19
		if facing_right:
			$AnimatedSprite.scale.x = 1
			$AnimatedSprite.position.x = 5
			$AttackArea/CollisionShape2D.position.x = 36
			$Camera2D.offset_h = .55
			$LightOccluder2D.scale.x = 1
			$BloodballPlacer.position.x = 33
		else:
			$AnimatedSprite.scale.x = -1
			$AnimatedSprite.position.x = -5
			$AttackArea/CollisionShape2D.position.x = -36
			$Camera2D.offset_h = -.55
			$LightOccluder2D.scale.x = -1
			$BloodballPlacer.position.x = -33
	else:motion.x = lerp(motion.x, 0, .05)
	
#	// ENABLE PHASE WHEN ROLLING //
	if isRolling:
		$AnimatedSprite.speed_scale = 1
		set_collision_mask_bit(2, false)
		set_collision_layer_bit(0, false)
		$PlayerHurtbox.set_collision_mask_bit(2, false)
	else:
		set_collision_mask_bit(2, true)
		set_collision_layer_bit(0, true)
		$PlayerHurtbox.set_collision_mask_bit(2, true)
	
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

func setMaxSpeed():
	if isRolling:
		return 350
	elif isSprinting:
		return 400
	elif isCrouching:
		return 100
	return 200

#Stops player from getting hit or moving when dead
func die():
	isAlive = false
	isAttacking = false
	$Death.play()
	$AnimatedSprite.play("Death") 
	apply_gravity()
	$PlayerHurtbox/CollisionShape2D.disabled = true
	$SpawnTimer.start()

func spawn():
	position = spawnPosition
	isAlive = true;facing_right = true
	_set_health(max_health)
	blinker.start_blinking(self,invincibility_duration)
	hurtbox.start_invincibility(invincibility_duration)	

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
	return stamina

func _set_blood(value):
	var prev_blood = blood_gauge
	blood_gauge = clamp (value,0, max_blood)
	if blood_gauge != prev_blood:
		emit_signal("blood_gauge_updated", blood_gauge)
	return blood_gauge

#Makes player invincible for certain amount of time
func takeDamage(damage):
	$StunTimer.start()
	$AnimatedSprite.play("Hit")
	$TakeDamage.play()
	_set_blood(blood_gauge + damage*.2)
	current_health = _set_health(health - damage)
	if current_health > clamp (0,0,max_health):
		hurtbox.player_hit(true)
		blinker.start_blinking(self,invincibility_duration)
		hurtbox.start_invincibility(invincibility_duration)	

func apply_knockback(direction):
	if direction:
		motion = Vector2(200, -150)
	else:
		motion = Vector2(-200, -150)
	MAXSPEED = 200
	facing_right = !direction

#called from enemy
func _on_Enemy_hit(damage, dir_right):
	if $Blinker/BlinkTimer.is_stopped() && isAlive && !isRolling:
		takeDamage(damage)
		apply_knockback(dir_right)

func _on_AttackArea_body_entered(body):
	if body in get_tree().get_nodes_in_group("Enemy"):
		body.take_damage(playerDamage, facing_right)
		_set_blood(blood_gauge + 10)
		var PosX = body.position.x - position.x
		if (body.enemyType == "Hero"):
			if (body.is_moving_right == true and PosX > 0):
				body.get_node("AnimationPlayer").play("TakeHit")
				body.is_moving_right = false
				body.scale.x = -body.scale.x
			elif (body.is_moving_right == false and PosX < 0):
				body.get_node("AnimationPlayer").play("TakeHit")
				body.is_moving_right = true
				body.scale.x = -body.scale.x
		


func _on_PlayerHurtbox_area_entered(area):
	if area in get_tree().get_nodes_in_group("Checkpoint"):
		spawnPosition = area.position;return
	var body = area.get_parent()
	if body in get_tree().get_nodes_in_group("Enemy"):
		if (body.isDead == false) && (!isRolling):
			takeDamage(body.damage)
			apply_knockback(position.x > body.position.x)
	if body in get_tree().get_nodes_in_group("Trap"):
		takeDamage(1000)

func _on_AnimatedSprite_animation_finished():
#	// STOP ATTACK STATE //
	if $AnimatedSprite.animation == "Attack" or $AnimatedSprite.animation == "Attack2":
		isAttacking = false
	if $AnimatedSprite.animation == "Range Attack":
		isRangeAttacking = false
	if $AnimatedSprite.animation == "Hit":
		isAttacking = false
		isRolling = false
		isRangeAttacking = false
	if $AnimatedSprite.animation == "Roll":
		isRolling = false
	if $AnimatedSprite.animation =="Turn Around":
		isTurning = false
#	if $AnimatedSprite.animation == ""

func _on_SpawnTimer_timeout():
	spawn()

func Posion():
	isPoisoned = false 
