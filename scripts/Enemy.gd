extends KinematicBody2D
signal hit(damage, dir)

var is_moving_right = true 

var gravity = 9.8
var velocity = Vector2(0,0)
var speed = -30
var isAttacking = false;
var animation = false;
var inRange = false 
var damage = 100
var isDead = false


func _ready():
	$AnimationPlayer.play("Walk")
	connect("hit", get_tree().get_nodes_in_group("Player")[0], "_on_Enemy_hit")
	if (get_node(".").name == "Goblin"):
		speed = -50 
		damage = 70
	elif (get_node(".").name == "Skeleton"): 
		speed = -30
		damage = 100


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
	$HitBox.monitoring = false
	$EnemyHitBox.monitoring = false
	$PlayerDetector.monitoring = false
	set_collision_mask_bit(3, false)
	$Timer.start()

func _on_HitBox_body_entered(body):
	print(body.name)
	emit_signal("hit", damage, is_moving_right)


func _on_Timer_timeout():
	queue_free()

func Fireball():
	var fireattack = Fireball.instance()
	if (is_moving_right == true):
		fireattack.set_fireball_direction(1)
	else:
		fireattack.set_fireball_direction(-1)					
		get_parent().add_child(fireattack)
		fireattack.global_position = $FireBallPlacer.global_position
