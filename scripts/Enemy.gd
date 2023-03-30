extends KinematicBody2D
signal hit(damage, dir)

export var is_moving_right = false 
var initialDirection
var gravity = 9.8
var velocity = Vector2(0,0)
var speed;
var isAttacking = false
var animation = false
var inRange = false 
var damage = 100
var isDead = false
var seeWall = false 
var health = 1000
var weaponType

const Fireball = preload("res://Scenes/FireBall.tscn")

func _ready():
	$AnimationPlayer.play("Walk")
	connect("hit", get_tree().get_nodes_in_group("Player")[0], "_on_Enemy_hit")
	if !is_moving_right:
		scale.x = -scale.x;
	if (get_node(".").name == "Goblin"):
		health = 100
		speed = -50
		weaponType = "Melee"
		damage = 70
	elif (get_node(".").name == "Skeleton"): 
		health = 200
		speed = -30
		damage = 100
		weaponType = "Melee"
	elif (get_node(".").name == "FireWorm"): 
		health = 100
		speed = -30
		damage = 100
		weaponType = "Ranged"

func _process(delta):
	if (isDead == false):
		if (isAttacking != true && inRange == false && $AnimationPlayer.current_animation != "Attack"):
			move_character()
			detect_turn_around()
		if ($AnimationPlayer.current_animation == "Attack"):
			return	

		if is_on_wall():
			is_moving_right = !is_moving_right
			scale.x = -scale.x


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
		$AnimationPlayer.play("Attack")
		inRange = true 

	

func hit():
	$HitBox.monitoring = true 
	$Attack.play()


func end_of_hit():
	$HitBox.monitoring = false  

func _on_PlayerDetector_body_exited(body):
	inRange = false 

func _on_AnimationPlayer_animation_finished(anim_name):
	if (anim_name == "Attack" && seeWall == false):
		if (inRange):
			$AnimationPlayer.play("Attack")
		else:
			isAttacking = false 
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


func _on_Timer_timeout():
	queue_free()

func _on_WallDetector_body_entered(body):
	seeWall = true


func _on_WallDetector_body_exited(body):
	seeWall = false 

func Fireball():
	$Attack.play()
	var fireattack = Fireball.instance()
	if (is_moving_right == true):
		fireattack.set_fireball_direction(1)
	else:
		fireattack.set_fireball_direction(-1)					
	get_parent().add_child(fireattack)
	fireattack.global_position = $FireBallPlacer.global_position
 
