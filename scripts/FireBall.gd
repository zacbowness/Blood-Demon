extends Area2D
signal hit(damage, dir)

const speed = 200
var velocity = Vector2()
var direction = 1
var damage = 50
var is_moving_right = true



func _ready():
	connect("hit", get_tree().get_nodes_in_group("Player")[0], "_on_Enemy_hit")
	$Light2D.texture_scale = .25

func set_fireball_direction(dir):
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

func _on_Fireball_body_entered(body):
	$AnimationPlayer.play("Explode")
	set_physics_process(false)
	if (body.name == "Player"):
		emit_signal("hit", damage, is_moving_right)
