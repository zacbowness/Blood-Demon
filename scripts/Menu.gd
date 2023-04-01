extends Node2D


export var mainGameScene : PackedScene
var menu_origin_position := Vector2.ZERO
var menu_origin_size := Vector2.ZERO
var menu_transition_time := 0.5 

var current_menu
var menu_stack := []

onready var menu_1 = $MainMenu
onready var menu_2 = $ControlsMenu
onready var tween = $Tween

func _ready():
	menu_origin_position = Vector2(0,0)
	menu_origin_size = get_viewport_rect().size
	current_menu = menu_1
	$MenuMusic.play()
	$MainMenu/VBoxContainer/VBoxContainer/MarginContainer/NewGameButton.grab_focus()

#Moves from the main menu to the control menu
func move_to_next_menu(next_menu_id:String):
	var next_menu = get_menu_from_menu_id(next_menu_id)
	#current_menu.rect_global_position = Vector2(0, menu_origin_size.y)
	#next_menu.rect_global_position = menu_origin_position
	tween.interpolate_property(current_menu, "rect_global_position", current_menu.rect_global_position, Vector2(0, -menu_origin_size.y), menu_transition_time)
	tween.interpolate_property(next_menu, "rect_global_position", next_menu.rect_global_position, menu_origin_position, menu_transition_time)
	tween.start()
	menu_stack.append(current_menu)
	current_menu = next_menu

#Moves from Control menu to main menu	
func move_to_prev_menu():
	var previous_menu = menu_stack.pop_back()
	if previous_menu != null:
		#previous_menu.rect_global_position = menu_origin_position
		#current_menu.rect_global_position = Vector2(0, -menu_origin_size.y)
		tween.interpolate_property(previous_menu, "rect_global_position", previous_menu.rect_global_position, menu_origin_position, menu_transition_time)
		tween.interpolate_property(current_menu, "rect_global_position", current_menu.rect_global_position, Vector2(0, menu_origin_size.y), menu_transition_time)
		tween.start()
		current_menu = previous_menu

#Gets the menu id from a string
func get_menu_from_menu_id(menu_id: String) -> Control:
	match menu_id:
		"menu_1":
			return menu_1
		"menu_2":
			return menu_2
		_:
			return menu_1

#Makes the background scroll
func _process(delta):
	$ParallaxBackground.scroll_base_offset -= Vector2(100,0) * delta
	
#Stops music, plays sound effect, and then brings you to the main game
func _on_NewGameButton_pressed():
	$MenuMusic.stop()
	$StartGame.play()
	get_tree().get_root().set_disable_input(true)
	yield(get_tree().create_timer(1.5),"timeout")
	get_tree().change_scene(mainGameScene.resource_path)
	get_tree().get_root().set_disable_input(false)

#Quit the game
func _on_QuitButton_pressed():
	get_tree().quit()

#Brings you to the Controls Menu
func _on_ControlsButton_pressed():
	$ButtonClick.play()
	move_to_next_menu("menu_2")
	get_tree().get_root().set_disable_input(true)
	yield(get_tree().create_timer(0.5),"timeout")
	$ControlsMenu/BackButton/Back.grab_focus()
	get_tree().get_root().set_disable_input(false)

func _on_ControlsButton_mouse_entered():
	$MainMenu/VBoxContainer/VBoxContainer/MarginContainer2/ControlsButton.grab_focus()

func _on_QuitButton_mouse_entered():
	$MainMenu/VBoxContainer/VBoxContainer/MarginContainer3/QuitButton.grab_focus()

func _on_NewGameButton_mouse_entered():
	$MainMenu/VBoxContainer/VBoxContainer/MarginContainer/NewGameButton.grab_focus()

#Brings you back to main menu
func _on_Back_pressed():
	$ButtonClick.play()
	move_to_prev_menu()
	get_tree().get_root().set_disable_input(true)
	yield(get_tree().create_timer(0.5),"timeout")
	$MainMenu/VBoxContainer/VBoxContainer/MarginContainer2/ControlsButton.grab_focus()
	get_tree().get_root().set_disable_input(false)
	
