extends KinematicBody2D

const UP = Vector2(0, -1)
const GRAVITY = 15*5
const MAXFALLSPEED = 200*5
const MAXSPEED = 80*5
const JUMPFORCE = 200*5
const ACCEL = 10*5

var motion = Vector2()
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _physics_process(delta):
	
	motion.y += GRAVITY
	if motion.y > MAXFALLSPEED:
		motion.y = MAXFALLSPEED
	
	motion.x = clamp(motion.x, -MAXSPEED, MAXSPEED)
	
	if Input.is_action_pressed("move_right"):
		motion.x += ACCEL
	elif Input.is_action_pressed("move_left"):
		motion.x -= ACCEL
	else:
		motion.x = lerp(motion.x, 0, 0.2)
	
	if is_on_floor():
		if Input.is_action_pressed("jump"):
			motion.y = -JUMPFORCE
	
	motion = move_and_slide(motion, UP)
