class_name GameUI
extends CanvasLayer

@onready var health_bar: ProgressBar = $MarginContainer/VBoxContainer/HealthBar
@onready var xp_bar: ProgressBar = $MarginContainer/VBoxContainer/XPBar
@onready var level_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/LevelLabel
@onready var gold_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/GoldLabel
@onready var kills_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/KillsLabel
@onready var time_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/TimeLabel

var game_time: float = 0.0

func _ready() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_node("StatsManager"):
		connect_to_stats(player.stats)

func _process(delta: float) -> void:
	game_time += delta
	update_time_display()

func connect_to_stats(stats: StatsManager) -> void:
	stats.stat_changed.connect(_on_stat_changed)
	stats.level_up.connect(_on_level_up)
	
	update_health(stats.current_health, stats.max_health)
	update_xp(stats.current_xp, stats.xp_to_next_level)
	update_level(stats.player_level)
	update_gold(stats.current_gold)
	update_kills(stats.enemies_killed)

func _on_stat_changed(stat_name: String, _old_value, new_value) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player or not player.has_node("StatsManager"):
		return
	
	var stats = player.stats
	
	match stat_name:
		"health":
			update_health(stats.current_health, stats.max_health)
		"gold":
			update_gold(new_value)
		"xp":
			update_xp(stats.current_xp, stats.xp_to_next_level)
		"kills":
			update_kills(new_value)
		"score":
			pass

func _on_level_up(new_level: int) -> void:
	update_level(new_level)
	
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_node("StatsManager"):
		update_xp(player.stats.current_xp, player.stats.xp_to_next_level)

func update_health(current: int, maximum: int) -> void:
	if health_bar:
		health_bar.max_value = maximum
		health_bar.value = current

func update_xp(current: int, to_next: int) -> void:
	if xp_bar:
		xp_bar.max_value = to_next
		xp_bar.value = current

func update_level(level: int) -> void:
	if level_label:
		level_label.text = "Level: " + str(level)

func update_gold(amount: int) -> void:
	if gold_label:
		gold_label.text = "Gold: " + str(amount)

func update_kills(amount: int) -> void:
	if kills_label:
		kills_label.text = "Kills: " + str(amount)

func update_time_display() -> void:
	if time_label:
		var minutes = int(game_time) / 60
		var seconds = int(game_time) % 60
		time_label.text = "Time: %02d:%02d" % [minutes, seconds]
