class_name PauseMenu
extends CanvasLayer

@onready var panel: Panel = $Panel
@onready var resume_button: Button = $Panel/MarginContainer/VBoxContainer/ResumeButton
@onready var main_menu_button: Button = $Panel/MarginContainer/VBoxContainer/MainMenuButton
@onready var quit_button: Button = $Panel/MarginContainer/VBoxContainer/QuitButton

func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	if resume_button:
		resume_button.pressed.connect(_on_resume_pressed)
	
	if main_menu_button:
		main_menu_button.pressed.connect(_on_main_menu_pressed)
	
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause() -> void:
	if get_tree().paused:
		resume()
	else:
		pause()

func pause() -> void:
	get_tree().paused = true
	show()

func resume() -> void:
	get_tree().paused = false
	hide()

func _on_resume_pressed() -> void:
	resume()

func _on_main_menu_pressed() -> void:
	print("Changing to main menu...")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
