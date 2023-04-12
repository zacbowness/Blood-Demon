extends KinematicBody2D
signal hit(damage, dir)
signal Boss_health_updated(health)
signal noPoison

const red_duration = 0.15
export var is_moving_right = false 
var initialDirection
var gravity = 9.8
var velocity = Vector2(0,0)
export (int) var  speed = 0;
var isAttacking = false
var animation = false
var inRange = false 
var amountHit = 0
export (int) var damage = 100
var isDead = false
var seeWall = false 
export (int) var health = 1000
var weaponType
var movementType
export (String) var enemyType
var attackCounter = 0 
enum {
	IDLE,
	ATTACK,
	DAMAGED,
	CHASE,
	DEAD
}

var state = CHASE

export var Projectile : PackedScene

onready var player = get_tree().get_nodes_in_group("Player")[0]

func _ready():
	connect("hit", get_tree().get_nodes_in_group("Player")[0], "_on_Enemy_hit")
	connect("noPoison", get_tree().get_nodes_in_group("Player")[0], "Posion")
	connect("Boss_health_updated", get_parent().get_node("HUD"), "_on_Boss_health_updated")
	if !is_moving_right:
		scale.x = -scale.x;


func _process(delta):
	match state:
		IDLE:
			pass
		ATTACK:
			isAttacking = true 
			$AnimationPlayer.play("Attack")
		CHASE:
			$AnimationPlayer.play("Walk")
			move_character()
			detect_turn_around()
			$PlayerDetector.monitoring = true
			if is_on_wall():
				is_moving_right = !is_moving_right
				scale.x = -scale.x	
			if player:
				var PosX = player.position.x - position.x
				if (is_moving_right == true and PosX < 0):
					is_moving_right = false
					scale.x = -scale.x
				elif (is_moving_right == false and PosX > 0):
					is_moving_right = true
					scale.x = -scale.x
		DEAD:
			pass
		DAMAGED:
			$AnimationPlayer.play("TakeHit")
			$PlayerDetector.monitoring = false
	
func move_character():
	velocity.x = -speed if is_moving_right else speed
	velocity.y += gravity
	velocity = move_and_slide(velocity, Vector2.UP)

func detect_turn_around():
	if not $RayCast2D.is_colliding() and is_on_floor():
		is_moving_right = !is_moving_right
		scale.x = -scale.x

func _on_PlayerDetector_body_entered(body):
	if (seeWall == false ):
		state = ATTACK
		inRange = true 

func hit():
	$HitBox.monitoring = true 
	if (attackCounter != 3):
		$Attack.play()
	else:
		Fireball()
		$Fireball.play()
		attackCounter = 0		

func end_of_hit():
	$HitBox.monitoring = false  
	attackCounter = attackCounter + 1

func _on_PlayerDetector_body_exited(body):
	inRange = false 

func take_damage(damage, dir):
	var sprite = get_node("Sprite")
	health = (health - damage)
	emit_signal("Boss_health_updated", health)
	if (isAttacking == true):
		amountHit = amountHit + 1
	if (health <= 0):
		death()
	elif (amountHit == 3):
		state = DAMAGED
	sprite.material.set_shader_param("red",true)
	yield(get_tree().create_timer(red_duration),"timeout")
	sprite.material.set_shader_param("red",false)

func _on_AnimationPlayer_animation_finished(anim_name):
	if (anim_name == "Attack" && seeWall == false):
		if (inRange):
			state = ATTACK
		else:
			state = CHASE
	elif (anim_name == "TakeHit"):
		state = CHASE 
	elif anim_name == "Death":
		get_parent().get_node("HUD").get_node("BossHealthBar").visible = false
		yield(get_tree().create_timer(1),"timeout")
		get_parent().get_node("Transition/AnimationPlayer").play("Fade_in")
		
func death():
	state = DEAD
	isDead = true 
	speed = 0
	z_index = -1
	set_physics_process(false)
	$CollisionShape2D.set_deferred("disabled", true)
	$AnimationPlayer.play("Death")
	$Death.play()
	$HitBox.monitoring = false
	$EnemyHitBox.monitoring = false
	$PlayerDetector.monitoring = false
	set_collision_mask_bit(3, false)
	$Timer.start()

func _on_HitBox_body_entered(body):
	emit_signal("hit", damage, is_moving_right)
	if (enemyType == "ElfSpear"): 
		$Poision.start()
		body.isPoisoned = true 
		

func _on_Timer_timeout():
	queue_free()

func _on_Poision_timeout():
	emit_signal("noPoison")

func _on_WallDetector_body_entered(body):
	seeWall = true


func _on_WallDetector_body_exited(body):
	seeWall = false 

func Fireball():
	$Attack.play()
	var Attack = Projectile.instance()
	if (is_moving_right == true):
		Attack.set_fireball_direction(1)
	else:
		Attack.set_fireball_direction(-1)					
	get_parent().add_child(Attack)
	Attack.global_position = $FireBallPlacer.global_position

func attackStart():
	amountHit = 0
	
 



