extends Node2D

var goblin = preload("res://Scenes/Goblin.tscn")
var slime = preload("res://Scenes/PoisonSlime.tscn")
var ElfSpear = preload("res://Scenes/ElfSpear.tscn")
var ElfBow = preload("res://Scenes/ElfBow.tscn")
var spawn_enemy = true
var motion = Vector2()
onready var posion_timer = $PoisonTimer

onready var Goblin = $Goblin
onready var Goblin_1 = $Positions/PositionGob1/Goblin
onready var Goblin_speed = Goblin.speed
onready var Goblin_gravity = Goblin.gravity
onready var Goblin_z_index = Goblin.z_index
var enemy_1 = goblin.instance()
var dead_elves = 0 

func _ready():
	$Player/AudioStreamPlayer.play()
	$ElfBow2.airSpawn = false
	$ElfBow2.speed = 0

func _process(delta):
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

func _on_Area2D3_body_entered(body):
	spawn_elves($Positions/PositionElfSpear4,ElfSpear)
	spawn_elves($Positions/PositionElfSpear5,ElfSpear)
	$Area2D3/CollisionShape2D.set_deferred("disabled", true)
	
func secret_path():
	if $Blockade.visible == true:
		if not $ElfBow2.isDead == false:
			$Player/Success.play()
			$Blockade/StaticBody2D/CollisionShape2D.set_deferred("disabled",true)
			$Blockade.visible = false
