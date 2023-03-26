extends Area2D

const whiten_duration = 0.15
export (ShaderMaterial) var whiten_material
onready var collision_shape = $CollisionShape2D

#Creates the flashing affect to indicate period of invincibility 
func start_invincibility (invincibility_duration):
	collision_shape.set_deferred("disabled",true)
	yield(get_tree().create_timer(invincibility_duration),"timeout")
	collision_shape.set_deferred("disabled",false)

#Player flashes white when enemy attack hits
func player_hit(area: Area2D) -> void:
	flash ()

#Player flashes white when hitting enemy body 
func _on_PlayerHurtbox_area_entered(area: Area2D) -> void:
	flash ()

#The function called to make character flash white
func flash ():
	whiten_material.set_shader_param("whiten",true)
	yield(get_tree().create_timer(whiten_duration),"timeout")
	whiten_material.set_shader_param("whiten",false)
