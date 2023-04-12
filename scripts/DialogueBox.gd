extends Control

var skelly_dialog = [
	"Hey there, my name is Skelly",
	"I was instructed by the Blood Demon himself to explain how your new powers work.",
	"Firstly, the green bar at the top of the screen represents your health.",
	"I don't think I need to explain how that works.",
	"Secondly, the blue bar represents your stamina.",
	"You won't be able to run, dodge, or attack if it's empty.",
	"Although, you probably know that already.",
	"Finally, the red bar at the top of your screen is your blood gauge.", 
	"Hitting enemies or getting hit yourself fills it up.",
	"When your blood gauge is full enough you can release a BloodBall to attack enemies from a distance.",
	"I'll let you figure out everything else on your own.",
	"Good luck trying to kill the hero. You're going to need it."
]

var dialog_index = 0
var finished = false
# Called when the node enters the scene tree for the first time.
func _ready():
	load_dialog()
	
func _physics_process(delta):
	$Cursor.visible = finished
	if Input.is_action_just_pressed("ui_accept"):
		load_dialog()

func load_dialog():
	if dialog_index < skelly_dialog.size():
		finished = true
		$RichTextLabel.bbcode_text = skelly_dialog[dialog_index]
		$RichTextLabel.percent_visible = 0
		$Tween.interpolate_property($RichTextLabel,"percent_visible", 0,1,1,Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.start()
	else:
		queue_free()
	dialog_index +=1



func _on_Tween_tween_completed(object, key):
	finished = true
