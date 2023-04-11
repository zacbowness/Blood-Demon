extends Node2D

export var mainGameScene : PackedScene
var goblin = preload("res://Scenes/Goblin.tscn")
var slime = preload("res://Scenes/PoisonSlime.tscn")
var ElfSpear = preload("res://Scenes/ElfSpear.tscn")
var ElfBow = preload("res://Scenes/ElfBow.tscn")
var flyingEye = preload("res://Scenes/FlyEye.tscn")
var knight = preload("res://Scenes/Knight.tscn")
onready var posion_timer = $PoisonTimer
onready var castle_Position = $CastleEntrance
onready var player_Position = $Player.position
var death_count = 0
var enemy_count = 0
var timer_finished = false
var boss_spawn = false
var enemy_positions = []
var enemy_type = []
var enemy_movement = []

func _ready():
	$Player/AudioStreamPlayer.play()
	$Transition/CanvasOverlay/Overlay.color.a = 0
	for body in get_tree().get_nodes_in_group("Enemy"):
		enemy_positions.append(body.position)
		enemy_type.append(body.enemyType)
		enemy_movement.append(body.is_moving_right)

func _process(delta):
	player_Position = position
	if death_count == enemy_count and timer_finished == true and boss_spawn == false:
		var boss = knight.instance()
		boss.position = $FinalArea/BossPosition.position
		boss.enemyType = "KnightBoss"
		boss.player = get_node("/root/Forest/Player")
		add_child(boss)
		boss_spawn = true
	
#Spawning two goblins when entering a certain area
func _on_Area2D_area_entered(area):
	$Area2D/CollisionShape2D.set_deferred("disabled", true)
	var enemy_1 = goblin.instance()
	enemy_1.position = $Positions/PositionGob1.position
	var enemy_2 = goblin.instance()
	enemy_2.position = $Positions/PositionGob2.position
	add_child(enemy_1)
	enemy_1.speed = 0 
	enemy_1.saved_speed = -50
	enemy_1.airSpawn = true
	enemy_2.is_moving_right = true 
	add_child(enemy_2)
	enemy_2.speed = 0
	enemy_2.saved_speed = -50
	enemy_2.airSpawn = true
		
#Spawns slimes falling from the sky
func _on_Timer_timeout():
	spawn_enemy($Positions/PoisionPosition.position,slime)
	spawn_enemy($Positions/PosionPosition2.position,slime)
	spawn_enemy($Positions/PosionPosition3.position,slime)
	
func spawn_elves (location, enemy):
	var enemy_spawn = enemy.instance()
	enemy_spawn.position = location.position
	add_child(enemy_spawn)

func spawn_enemy (location, enemy):
	var enemy_spawn = enemy.instance()
	enemy_spawn.position = location
	add_child(enemy_spawn)

func spawn (location,enemy):
	var elf = enemy.instance()
	elf.is_moving_right = true
	elf.position = location.position
	add_child(elf)
	
func _on_Area2D2_area_entered(area):
	$Area2D2/CollisionShape2D.set_deferred("disabled",true)
	var special_Elf = ElfBow.instance()
	special_Elf.position = $Positions/SpecialElfBow.position
	special_Elf.is_moving_right = true
	special_Elf.special_enemyType = true 
	add_child(special_Elf)
	spawn($Positions/PositionElfSpear, ElfSpear)
	spawn($Positions/PositionElfSpear2,ElfSpear)
	spawn($Positions/PositionElfSpear3, ElfSpear)

#This is on a different layer than the other areas
func _on_Area2D3_body_entered(body):
	spawn_elves($Positions/PositionElfSpear4,ElfSpear)
	spawn_elves($Positions/PositionElfSpear5,ElfSpear)
	$Area2D3/CollisionShape2D.set_deferred("disabled", true)
	
func secret_path():
	$Player/Success.play()
	$Blockade/StaticBody2D/CollisionShape2D.set_deferred("disabled",true)
	$Blockade.visible = false

func _on_Area2D4_area_entered(area):
	$FloorBlockade.visible = false
	$FloorBlockade/StaticBody2D/CollisionShape2D.set_deferred("disabled",true)

func _death_count():
	death_count = death_count + 1
	
func enemy_numbers():
	enemy_count = enemy_count + 1

func _on_Area2D5_area_entered(area):
	$FinalArea/StartTimer.start()
	$FinalArea/SurviveLabel.visible = true
	$Area2D5/CollisionShape2D.set_deferred("disabled",true)

func _on_StartTimer_timeout():
	$FinalArea/SurvivalTimer.start()
	$FinalArea/SurviveLabel.visible = false
	death_count = 0
	final_Spawn_Eyes()
	$FinalArea/SpawnTimer.start()
	yield(get_tree().create_timer(1),"timeout")
	final_Spawn_Goblins()
	$FinalArea/SpawnTimer2.start()
	yield(get_tree().create_timer(2),"timeout")
	final_Spawn_ElfSpear()
	$FinalArea/SpawnTimer3.start()
	yield(get_tree().create_timer(3),"timeout")
	final_Spawn_ElfBow()
	$FinalArea/SpawnTimer4.start()
	
func final_Spawn (location,enemy,moving_right):
	var enemy_spawn = enemy.instance()
	if moving_right == true:
		enemy_spawn.is_moving_right = true
	enemy_spawn.position = location.position
	add_child(enemy_spawn)
	
func final_Spawn_Eyes():
	final_Spawn($FinalArea/FinalFlyingEye, flyingEye, false)
	final_Spawn($FinalArea/FinalFlyingEye2, flyingEye, true)
	enemy_count += 2

func final_Spawn_Goblins():
	final_Spawn($FinalArea/FinalGoblin, goblin, false)
	final_Spawn($FinalArea/FinalGoblin2, goblin, true)
	enemy_count += 2

func final_Spawn_ElfSpear():
	final_Spawn($FinalArea/FinalSpearElf,ElfSpear, true)
	final_Spawn($FinalArea/FinalSpearElf2,ElfSpear, false)
	enemy_count += 2
	
func final_Spawn_ElfBow():
	final_Spawn($FinalArea/FinalElfBow,ElfBow, true)
	final_Spawn($FinalArea/FinalElfBow2,ElfBow, false)
	enemy_count += 2

func _on_SpawnTimer_timeout():
	final_Spawn_Eyes()

func _on_SpawnTimer2_timeout():
	final_Spawn_Goblins()

func _on_SpawnTimer3_timeout():
	final_Spawn_ElfSpear()

func _on_SpawnTimer4_timeout():
	final_Spawn_ElfBow()
	
func _on_SurvivalTimer_timeout():
	$Player/Success.play()
	$FinalArea/SpawnTimer.stop()
	$FinalArea/SpawnTimer2.stop()
	$FinalArea/SpawnTimer3.stop()
	$FinalArea/SpawnTimer4.stop()
	timer_finished = true
	
func boss_Dead():
	$TallBlockade2.visible = false
	$TallBlockade2/StaticBody2D/CollisionShape2D.set_deferred("disabled", true)
	#$Transition/AnimationPlayer.play("Fade_in")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Fade_in":
		get_tree().change_scene(mainGameScene.resource_path)
	
func adding_enemies(location,enemy,moving_right):
	var enemy_scene;
	if str(enemy) == "ElfBow":
		enemy_scene = ElfBow
	if str(enemy) == "ElfSpear":
		enemy_scene = ElfSpear
	if str(enemy) == "Goblin":
		enemy_scene = goblin
	if str(enemy) == "FlyingEye":
		enemy_scene = flyingEye
	var enemy_spawn = enemy_scene.instance()
	if moving_right == true:
		enemy_spawn.is_moving_right = true
	enemy_spawn.position = location
	add_child(enemy_spawn)

func reset_enemies():
	$FinalArea/SpawnTimer.stop()
	$FinalArea/SpawnTimer2.stop()
	$FinalArea/SpawnTimer3.stop()
	$FinalArea/SpawnTimer4.stop()
	$FinalArea/SurvivalTimer.stop()
	for i in enemy_type.size():
		adding_enemies(enemy_positions[i],enemy_type[i],enemy_movement[i])


func _on_Player_respawn():
	get_tree().call_group("Enemy", "queue_free")
	$Area2D/CollisionShape2D.set_deferred("disabled",false)
	$Area2D2/CollisionShape2D.set_deferred("disabled",false)
	$Area2D3/CollisionShape2D.set_deferred("disabled",false)
	$Area2D4/CollisionShape2D.set_deferred("disabled",false)
	$Area2D5/CollisionShape2D.set_deferred("disabled",false)
	$Blockade/StaticBody2D/CollisionShape2D.set_deferred("disabled",false)
	$Blockade.visible = true
	$FloorBlockade.visible = true
	$FloorBlockade/StaticBody2D/CollisionShape2D.set_deferred("disabled",false)

#Currently this function does nothing but Zac is working on it
func _on_Area2D6_area_entered(area):
	var player_position 
	set_process_unhandled_input(false)
	while player_Position.x < Vector2(7352, 326).x:
		player_Position.x += 10*2
		$Player/AnimatedSprite.play("Run")
		$Player.facing_right = true
		$Player.isMoving = true
