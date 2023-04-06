extends KinematicBody2D
signal hit(damage, dir)
signal noPoison
signal deadCount(spawnedEnemy)
var spawnedEnemy;
const red_duration = 0.15
export var is_moving_right = false 
var initialDirection
var gravity = 9.8
var velocity = Vector2(0,0)
var speed;
var saved_speed;
var isAttacking = false
var animation = false
var inRange = false 
var damage = 100
var isDead = false
var seeWall = false 
var health = 1000
var weaponType
var movementType
var floor_now = false
var ElfBow_death_count;
var ElfSpear_death_count;
var airSpawn;

const Fireball = preload("res://Scenes/FireBall.tscn")
const Arrow = preload("res://Scenes/Arrow.tscn")

func _ready():
	$AnimationPlayer.play("Walk")
	connect("hit", get_tree().get_nodes_in_group("Player")[0], "_on_Enemy_hit")
	connect("noPoison", get_tree().get_nodes_in_group("Player")[0], "Posion")
	if !is_moving_right:
		scale.x = -scale.x;
	if (get_node(".").name == "Goblin" or "Goblin2"):
		health = 100
		speed = -50
		saved_speed = -50
		weaponType = "Melee"
		damage = 70
		movementType = "Ground"
	elif (get_node(".").name == "Skeleton"): 
		health = 200
		speed = -30
		saved_speed = -30
		damage = 100
		weaponType = "Melee"
		movementType = "Ground"
	elif (get_node(".").name == "FireWorm"): 
		health = 100
		speed = -30
		saved_speed = -30
		damage = 100
		weaponType = "Ranged"
		movementType = "Ground"
	elif (get_node(".").name == "Knight"): 
		health = 500
		speed = -20
		saved_speed = -20
		damage = 200
		weaponType = "Melee"
		movementType = "Ground"
	elif (get_node(".").name == "ElfBow"): 
		health = 100
		speed = -40
		saved_speed = -40
		damage = 100
		weaponType = "Ranged"
		movementType = "Ground"
	elif (get_node(".").name == "ElfSpear"): 
		health = 200
		speed = -40
		saved_speed = -40
		damage = 50
		weaponType = "Melee"
		movementType = "Ground"

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
	change_to_idle()
	change_to_walk()

func move_character():
	velocity.x = -speed if is_moving_right else speed
	velocity.y += gravity
	velocity = move_and_slide(velocity, Vector2.UP)

func detect_turn_around():
	if not $RayCast2D.is_colliding() and is_on_floor():
		is_moving_right = !is_moving_right
		scale.x = -scale.x

func _on_PlayerDetector_body_entered(body):
	if body in get_tree().get_nodes_in_group("Player"):
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

func take_damage(damage):
	var sprite = get_node("Sprite")
	health = (health - damage)
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
		
func death():
	isDead = true 
	speed = 0
	z_index = -1
	set_process(false)
	set_physics_process(false)
	$CollisionShape2D.set_deferred("disabled", true)
	$AnimationPlayer.play("Death")
	$Death.play()
	$HitBox.monitoring = false
	$EnemyHitBox.monitoring = false
	$PlayerDetector.monitoring = false
	set_collision_mask_bit(3, false)
	$Timer.start()
	if spawnedEnemy == true:
		emit_signal("deadCount")

func _on_HitBox_body_entered(body):
	emit_signal("hit", damage, is_moving_right)
	if (get_node(".").name == "ElfSpear"): 
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
	if (get_node(".").name == "FireWorm"): 
		$Attack.play()
		var fireattack = Fireball.instance()
		if (is_moving_right == true):
			fireattack.set_fireball_direction(1)
		else:
			fireattack.set_fireball_direction(-1)					
		get_parent().add_child(fireattack)
		fireattack.global_position = $FireBallPlacer.global_position
	elif (get_node(".").name == "ElfBow"): 	
		$Attack.play()
		var arrow = Arrow.instance()
		if (is_moving_right == true):
			arrow.set_fireball_direction(1)
		else:
			arrow.set_fireball_direction(-1)					
		get_parent().add_child(arrow)
		arrow.global_position = $FireBallPlacer.global_position
		
func change_to_idle():
	if	not is_on_floor():
		$AnimationPlayer.playback_speed = 0 
		
func change_to_walk():
	if is_on_floor() and floor_now == false:
		$AnimationPlayer.playback_speed = 1
		$AnimationPlayer.play("Walk")
		if airSpawn == true:
			speed = saved_speed 
		floor_now == true

func _on_ElfSpear_deadCount(spawnedEnemy):
	if spawnedEnemy == true:
		ElfSpear_death_count +=1
	

func _on_ElfBow_deadCount(spawnedEnemy):
	if spawnedEnemy == true:
		ElfBow_death_count +=1
