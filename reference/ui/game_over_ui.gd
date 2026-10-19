class_name GameOverUI
extends CanvasLayer

@onready var panel: Panel = $Panel
@onready var title_label: Label = $Panel/MarginContainer/VBoxContainer/TitleLabel
@onready var stats_label: Label = $Panel/MarginContainer/VBoxContainer/StatsLabel
@onready var restart_button: Button = $Panel/MarginContainer/VBoxContainer/RestartButton
@onready var quit_button: Button = $Panel/MarginContainer/VBoxContainer/QuitButton

func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	if restart_button:
		restart_button.pressed.connect(_on_restart_pressed)
	
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)

func show_game_over(stats: StatsManager, survival_time: float) -> void:
	var minutes = int(survival_time) / 60
	var seconds = int(survival_time) % 60
	
	var stats_text = ""
	stats_text += "Time Survived: %02d:%02d\n" % [minutes, seconds]
	stats_text += "Level Reached: %d\n" % stats.player_level
	stats_text += "Enemies Killed: %d\n" % stats.enemies_killed
	stats_text += "Gold Collected: %d\n" % stats.current_gold
	stats_text += "Final Score: %d" % stats.current_score
	
	if stats_label:
		stats_label.text = stats_text
	
	show()
	get_tree().paused = true

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_pressed() -> void:
	get_tree().quit()
