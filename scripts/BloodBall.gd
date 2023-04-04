extends Area2D
signal hit(damage)

const speed = 400
var velocity = Vector2()
var direction = 1
var damage = 50
var is_moving_right = true


func _ready():
	for enemy in get_tree().get_nodes_in_group("Enemy"):
		connect("hit", enemy, "take_damage")

func set_bloodball_direction(dir):
	direction = dir
	if (dir == -1):
		$Sprite.flip_h = true

	
func _physics_process(delta):
	velocity.x = speed * delta * direction
	if (direction == 1):
		is_moving_right = true 
	else:
		is_moving_right = false 
	translate(velocity)
	$AnimationPlayer.play("Shoot")

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func _on_BloodBall_body_entered(body):
	$AnimationPlayer.play("Explode")
	set_physics_process(false)
	if body in get_tree().get_nodes_in_group("Enemy"):
		body.take_damage(damage)
		var PosX = body.position.x - position.x
		if (body.is_moving_right == true and PosX > 0):
			body.get_node("AnimationPlayer").play("TakeHit")
			body.is_moving_right = false
			body.scale.x = -body.scale.x
		elif (body.is_moving_right == false and PosX < 0):
			body.get_node("AnimationPlayer").play("TakeHit")
			body.is_moving_right = true
			body.scale.x = -body.scale.x
