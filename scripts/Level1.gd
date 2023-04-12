extends Node2D

export var mainGameScene : PackedScene
var goblin = preload("res://Scenes/Goblin.tscn")
var flyingEye = preload("res://Scenes/FlyEye.tscn")
var knight = preload("res://Scenes/Knight.tscn")
var fireWorm = preload("res://Scenes/FireWorm.tscn")
var skeleton = preload("res://Scenes/Skeleton.tscn")
var hero = preload("res://Scenes/Hero.tscn")

var death_count = 0
var enemy_positions = []
var enemy_type = []
var enemy_movement = []
# Called when the node enters the scene tree for the first time.
func _ready():
	$Transition/AnimationPlayer.play("Fade_out")
	for body in get_tree().get_nodes_in_group("Enemy"):
		enemy_positions.append(body.position)
		enemy_type.append(body.enemyType)
		enemy_movement.append(body.is_moving_right)

func adding_enemies(location,enemy,moving_right):
	var enemy_scene;
	if str(enemy) == "FireWorm":
		enemy_scene = fireWorm
	if str(enemy) == "Skeleton":
		enemy_scene = skeleton
	if str(enemy) == "Knight":
		enemy_scene = knight
	if str(enemy) == "FlyingEye":
		enemy_scene = flyingEye
	if str(enemy) == "Goblin":
		enemy_scene = goblin
	var enemy_spawn = enemy_scene.instance()
	if moving_right == true:
		enemy_spawn.is_moving_right = true
	enemy_spawn.position = location
	add_child(enemy_spawn)

func reset_enemies():
	for i in enemy_type.size():
		adding_enemies(enemy_positions[i],enemy_type[i],enemy_movement[i])

func _death_count():
	death_count = death_count + 1

func _on_Player_respawn():
	get_tree().call_group("Enemy", "queue_free")

func boss_Dead():
	$BossRoom/FloorFallTimer.start()
	
func _on_Area2D_body_entered(body):
	var hero_spawn = hero.instance()
	hero_spawn.position = $BossRoom/BossPosition.position
	hero_spawn.speed = -60
	add_child(hero_spawn)

func _on_FloorFallTimer_timeout():
	$FallingFloor.collision_layer = 5
