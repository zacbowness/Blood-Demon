extends Area2D

const whiten_duration = 0.15
export (ShaderMaterial) var whiten_material
onready var collision_shape = $CollisionShape2D

func start_invincibility (invincibility_duration):
	collision_shape.set_deferred("disabled",true)
	yield(get_tree().create_timer(invincibility_duration),"timeout")
	collision_shape.set_deferred("disabled",false)

func _on_PlayerHurtbox_area_entered(area: Area2D) -> void:
	whiten_material.set_shader_param("whiten",true)
	yield(get_tree().create_timer(whiten_duration),"timeout")
	whiten_material.set_shader_param("whiten",false)
