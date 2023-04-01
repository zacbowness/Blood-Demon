signal hit(damage, dir)
extends KinematicBody2D

export var Accel = 300 
export var MAX_SPEED = 200 

const red_duration = 0.15
var health = 100
var speed = 0
var weaponType = "Melee"
var damage = 70
var isDead = false 
var iPos
var inRange
var is_moving_right
enum {
	IDLE,
	RETURN,
	CHASE,
	DEAD
}

var velocity = Vector2.ZERO
var state = IDLE 

onready var playerDetectionZone = $PlayerDetectionZone

func _ready():
	iPos = position
	connect("hit", get_tree().get_nodes_in_group("Player")[0], "_on_Enemy_hit")

func _physics_process(delta):
	match state:
		IDLE:
			$AnimationPlayer.play("Walk")
			velocity = velocity.move_toward(Vector2.ZERO, 500 * delta)
			$Sprite.scale.x = -1
			$HitBox.position.x = -40.25
			$PlayerDetector.position.x = -40.25
			is_moving_right = false
			seek_player()
		RETURN: 
			$AnimationPlayer.play("Walk")
			var direction = (iPos - global_position).normalized()
			velocity = velocity.move_toward(MAX_SPEED * direction, Accel * delta)
			turnAround()
			seek_player()			
			if (position.y <= iPos.y):
				state = IDLE
		CHASE:
			var player = playerDetectionZone.player
			if player != null:
				var direction = (player.global_position + Vector2(0,25) - global_position).normalized()
				velocity = velocity.move_toward(MAX_SPEED * direction, Accel * delta)
			else:
				state = RETURN
			turnAround()	
		DEAD:
			pass
			
	print(get_collision_mask_bit(0))
	velocity = move_and_slide(velocity)
	
func turnAround():
	if (velocity.x < 0):
		$Sprite.scale.x = -1
		$HitBox.position.x = -40.25
		$PlayerDetector.position.x = -40.25
		is_moving_right = false
	elif (velocity.x > 0):
		$Sprite.scale.x = 1
		$HitBox.position.x = 0
		$PlayerDetector.position.x = 0
		is_moving_right = true
		
func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE 

func _on_PlayerDetector_body_entered(body):
	$AnimationPlayer.play("Attack")
	inRange = true 

func hit():
	$HitBox.monitoring = true 
	$Attack.play()


func end_of_hit():
	$HitBox.monitoring = false  

func take_damage(damage):
	var sprite = get_node("Sprite")
	health = (health - damage)
	sprite.material.set_shader_param("red",true)
	yield(get_tree().create_timer(red_duration),"timeout")
	sprite.material.set_shader_param("red",false)
	if (health <= 0):
		death()

func _on_PlayerDetector_body_exited(body):
	inRange = false 

func _on_AnimationPlayer_animation_finished(anim_name):
	if (anim_name == "Attack"):
		if (inRange):
			$AnimationPlayer.play("Attack")
		else:
			$AnimationPlayer.play("Walk")

func death():
	state = DEAD
	isDead = true 
	speed = 0
	z_index = -1
	velocity = velocity.move_toward(Vector2(0,200), 500)
	$AnimationPlayer.play("Death")
	$Death.play()
	$HitBox.monitoring = false
	$PlayerDetector.monitoring = false
	set_collision_mask_bit(0, false)
	set_collision_layer_bit(2, false)
	$Timer.start()

func _on_Timer_timeout():
	queue_free()
	
func _on_HitBox_body_entered(body):
	emit_signal("hit", damage, is_moving_right)
