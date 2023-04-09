extends Node2D

export var mainGameScene : PackedScene
var goblin = preload("res://Scenes/Goblin.tscn")
var slime = preload("res://Scenes/PoisonSlime.tscn")
var ElfSpear = preload("res://Scenes/ElfSpear.tscn")
var ElfBow = preload("res://Scenes/ElfBow.tscn")
var flyingEye = preload("res://Scenes/FlyEye.tscn")
var knight = preload("res://Scenes/Knight.tscn")
var spawn_enemy = true
var motion = Vector2()
onready var posion_timer = $PoisonTimer
var death_count = 0
var enemy_count = 0
var timer_finished = false
var boss_spawn = false

func _ready():
	$Player/AudioStreamPlayer.play()
	$Enemies/ElfBow2.airSpawn = false
	$Enemies/ElfBow2.speed = 0
	pass

func _process(delta):
	if death_count == enemy_count and timer_finished == true and boss_spawn == false:
		var boss = knight.instance()
		boss.position = $FinalArea/BossPosition.position
		boss.enemyType = "KnightBoss"
		boss.player = get_node("/root/Forest/Player")
		add_child(boss)
		boss_spawn = true
		
	secret_path()
	
#Spawning two goblins when entering a certain area
func _on_Area2D_area_entered(area):
	var enemy_1 = goblin.instance()
	enemy_1.position = $Positions/PositionGob1.position
	var enemy_2 = goblin.instance()
	enemy_2.position = $Positions/PositionGob2.position
	if spawn_enemy == true:
		add_child(enemy_1)
		enemy_1.speed = 0 
		enemy_1.saved_speed = -50
		enemy_1.airSpawn = true
		enemy_2.is_moving_right = true 
		add_child(enemy_2)
		enemy_2.speed = 0
		enemy_2.saved_speed = -50
		enemy_2.airSpawn = true
		spawn_enemy = false
		
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
	spawn($Positions/PositionElfSpear, ElfSpear)
	spawn($Positions/PositionElfSpear2,ElfSpear)
	spawn($Positions/PositionElfSpear3, ElfSpear)

#This is on a different layer than the other areas
func _on_Area2D3_body_entered(body):
	spawn_elves($Positions/PositionElfSpear4,ElfSpear)
	spawn_elves($Positions/PositionElfSpear5,ElfSpear)
	$Area2D3/CollisionShape2D.set_deferred("disabled", true)
	
func secret_path():
	if $Blockade.visible == true:
		if not $Enemies/ElfBow2.isDead == false:
			$Player/Success.play()
			$Blockade/StaticBody2D/CollisionShape2D.set_deferred("disabled",true)
			$Blockade.visible = false

func _on_Area2D4_area_entered(area):
	$FloorBlockade.visible = false
	$FloorBlockade/StaticBody2D/CollisionShape2D.set_deferred("disabled",true)

func _death_count():
	death_count = death_count + 1
	
func enemy_numbers():
	get_tree().change_scene(mainGameScene.resource_path) #remove this later
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

func _on_SurvivalTimer_timeout():
	$Player/Success.play()
	$FinalArea/SpawnTimer.stop()
	$FinalArea/SpawnTimer2.stop()
	$FinalArea/SpawnTimer3.stop()
	$FinalArea/SpawnTimer4.stop()
	timer_finished = true

func _on_SpawnTimer3_timeout():
	final_Spawn_ElfSpear()

func _on_SpawnTimer4_timeout():
	final_Spawn_ElfBow()
	
func boss_Dead():
	pass
