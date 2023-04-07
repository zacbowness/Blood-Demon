extends KinematicBody2D
signal hit(damage, dir)
signal noPoison

const red_duration = 0.15
export var is_moving_right = false 
var initialDirection
var gravity = 9.8
var velocity = Vector2(0,0)
var knockback = 0
export (int) var knockback_Amount = 200
export (int) var  speed = 0;
var isAttacking = false
var animation = false
var inRange = false 
export (int) var damage = 100
var isDead = false
var seeWall = false 
export (int) var health = 1000
var weaponType
var movementType
export (String) var enemyType

const Fireball = preload("res://Scenes/FireBall.tscn")
const Arrow = preload("res://Scenes/Arrow.tscn")
export var Projectile : PackedScene


func _ready():
	$AnimationPlayer.play("Walk")
	connect("hit", get_tree().get_nodes_in_group("Player")[0], "_on_Enemy_hit")
	connect("noPoison", get_tree().get_nodes_in_group("Player")[0], "Posion")
	if !is_moving_right:
		scale.x = -scale.x;

func _process(delta):
	if (isDead == false):
		move_character()
		detect_turn_around()
		
		if is_on_wall():
			is_moving_right = !is_moving_right
			scale.x = -scale.x


func move_character():
	knockback = lerp(knockback, 0, .09)
	if (!isAttacking && !inRange && $AnimationPlayer.current_animation != "Attack"):
		velocity.x = -speed if is_moving_right else speed
	else: velocity.x = 0
	velocity.x += knockback
	velocity.y += gravity
	velocity = move_and_slide(velocity, Vector2.UP)

func detect_turn_around():
	if not $RayCast2D.is_colliding() and is_on_floor():
		is_moving_right = !is_moving_right
		scale.x = -scale.x

func _on_PlayerDetector_body_entered(body):
	if (seeWall == false ):
		$AnimationPlayer.play("Attack")
		inRange = true 

func hit():
	$HitBox.monitoring = true 
	$Attack.play()

func end_of_hit():
	$HitBox.monitoring = false  

func _on_PlayerDetector_body_exited(body):
	inRange = false 

func take_damage(damage, dir):
	var sprite = get_node("Sprite")
	health = (health - damage)
	if dir:
		knockback += knockback_Amount
	else:
		knockback -= knockback_Amount
	sprite.material.set_shader_param("red",true)
	yield(get_tree().create_timer(red_duration),"timeout")
	sprite.material.set_shader_param("red",false)
	if (health <= 0):
		death()

func _on_AnimationPlayer_animation_finished(anim_name):
	if (anim_name == "Attack" && seeWall == false):
		if (inRange):
			$AnimationPlayer.play("Attack")
		else:
			isAttacking = false 
			$AnimationPlayer.play("Walk")
	elif (anim_name == "TakeHit"):
		$AnimationPlayer.play("Walk")
		
func death():
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

	
 



