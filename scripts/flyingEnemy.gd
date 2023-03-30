extends KinematicBody2D

var gravity = 9.8
var velocity = Vector2(0,0)
export var speed = 30
var isAttacking = false;
var animation = false;
var inRange = false 
var damage = 100
var isDead = false
var health = 100


#New variables:
var motion = Vector2()
export(String) var type
export(bool) var dir

func _physics_process(delta):
#	Up and down movement
	if type == "ud":
		if dir == true:
			motion.y = -speed
		if dir == false:
			motion.y = speed
		if $Up.is_colliding() == true && dir == true:
			dir = false
			print("Collision")
		if $Down.is_colliding() == true && dir == false:
			dir = true	
			print("Collision")
			
#	Left and right movement		
	if type == "lr":
		if dir == true:
			motion.x = -speed
		if dir == false:
			motion.x = speed
		if $Right.is_colliding() == true:
			dir = false
			print("Collision")
		if $Left.is_colliding() == true:
			dir = true	
			print("Collision")
		
			
	motion = move_and_slide(motion)


# Called when the node enters the scene tree for the first time.
func _ready():
	if type == "ud":
		$Up.enabled = true
		$Down.enabled = true
		$Left.enabled = false
		$Right.enabled = false
	if type == "lr":
		$Up.enabled = false
		$Down.enabled = false
		$Left.enabled = true
		$Right.enabled = true
		


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

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
