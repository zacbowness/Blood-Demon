extends Node2D

var death_count = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if $Enemies/Demon.isDead:
		$TextBoxes/GoodJob.visible = true

func _death_count():
	death_count = death_count + 1
