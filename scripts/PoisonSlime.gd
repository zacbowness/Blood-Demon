extends KinematicBody2D

var gravity = 20
var motion = Vector2()
export var damage = 50
	
# Called when the node enters the scene tree for the first time.
func _physics_process(delta):
	motion.y += gravity
	motion = move_and_slide(motion)

func _on_Area2D_area_entered(area):
	set_physics_process(false)
	$Slime.play("death")
	$Area2D/CollisionShape2D.set_deferred("disabled", true)
	$CollisionShape2D.set_deferred("disabled", true)

func _on_Slime_animation_finished():
	if $Slime.animation == "death":
		queue_free()

func _on_Area2D_body_entered(body):
	set_physics_process(false)
	$Slime.play("death")
	$Area2D/CollisionShape2D.set_deferred("disabled", true)
	$CollisionShape2D.set_deferred("disabled", true)
