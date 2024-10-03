extends Control

@onready var timer_label = $MarginContainer/CanvasLayer/TimerBox/TimerLabel
@onready var icon = $MarginContainer/CanvasLayer/Abilities/icon
@onready var cooldown = $MarginContainer/CanvasLayer/Abilities/icon/cooldown
@onready var reduced_time = $MarginContainer/CanvasLayer/ReducedTimer/reduced_time
@onready var times = $MarginContainer/CanvasLayer/accelerated_time/times
@onready var player_healthbar = $MarginContainer/CanvasLayer/PlayerHealthbar
@onready var primary_ability_overload = $MarginContainer/CanvasLayer/primary_ability_overload
@onready var primary_ability = $MarginContainer/CanvasLayer/primary_ability
@onready var activated_stone = $"MarginContainer/CanvasLayer/stone-tablet/Sprite2D/activated_stone"
@onready var cooldown_label = $MarginContainer/CanvasLayer/cooldown_label
@onready var cooldown_label_timer = $cooldown_label_timer


var teleport_icon = preload("res://Assets/Icon/portal_icon.png")
var punch_icon = preload("res://Assets/Icon/punch_icon.png")
var speed_icon = preload("res://Assets/Icon/speed.png")

var total_time = 14 * 60 + 59  # Total time (in seconds)
var time_left = total_time      # Remaining time (in seconds)
var time_multiplier = 1         # Timer speed multiplier

func _ready():
	icon.visible = false
	cooldown.visible = false
	reduced_time.visible = false
	times.visible = false
	#primary_ability.visible = false
	
	#update_timer_label()

func _process(delta):
	if time_left > 0:
		# Subtract the time based on delta and the time_multiplier
		time_left -= delta * time_multiplier
		
		# Ensure the time doesn't go below 0
		if time_left < 0:
			time_left = 0
		
		# Update the timer label each frame
		update_timer_label()

		# Show the time multiplier (if greater than 1)
		if time_multiplier > 1:
			times.visible = true
			times.text = "x" + str(time_multiplier)
			times.modulate = Color(255, 0, 0)  # Optional: Red color to indicate speed-up
		else:
			times.visible = false

		# Stop the game when the timer reaches 0
		if time_left == 0:
			print("GAME OVER!!")
			GameManager._changeScene(GameManager.game_over_menu)
			
	activated_stone.text = str(GameManager.total_tablet_secured) + "/6"

func update_timer_label():
	# Convert the remaining time into minutes and seconds
	var minutes = int(time_left) / 60
	var seconds = int(time_left) % 60
	
	# Format the time as MM:SS and update the label
	timer_label.text = "%02d:%02d" % [minutes, seconds]

func _on_player_ui_cooldown_time(cooldown_timer):
	cooldown.visible = true
	times.visible = true
	
	cooldown.text = str(cooldown_timer)
	if cooldown_timer > 0:
		icon.modulate = Color(128 / 255.0, 128 / 255.0, 128 / 255.0)
		cooldown.modulate = Color(255, 255, 255)
	else:
		icon.modulate = Color(1, 1, 1, 1)
		cooldown.visible = false
		times.visible = false

func _on_player_secondary_ui_icon(card_icon):
	icon.visible = true
	match card_icon:
		"Heavy_Punch":
			icon.texture = punch_icon
		"Teleport":
			icon.texture = teleport_icon
		"super_speed":
			icon.texture = speed_icon

func _on_player_depricate_time(random_time):
	display_reduced_time(random_time)
	time_left -= random_time

	if time_left < 0:
		time_left = 0

	update_timer_label()

	if time_left <= 0:
		print("GAME OVER!!")
		GameManager._changeScene(GameManager.game_over_menu)
		

func display_reduced_time(random_time):
	reduced_time.visible = true
	var reduced_minutes = int(random_time) / 60
	var reduced_seconds = int(random_time) % 60
	
	reduced_time.text = "-%02d:%02d" % [reduced_minutes, reduced_seconds]
	$AnimationPlayer.play("reduced_time_animation")

func _on_player_accelerated_timer(_times):
	# Signal received to accelerate the timer
	times.text = "x" + str(_times)
	time_multiplier = _times


func _on_player_health_bar_progress(current_health,max_health):
	updateHealthBar(current_health,max_health)

func updateHealthBar(current_health, max_health):
	var target_value = float(current_health * 100) / float(max_health)
	animate_health_change(target_value)

func animate_health_change(target_value) -> void:
	while abs(player_healthbar.value - target_value) > 0.01: 
		player_healthbar.value = lerp(float(player_healthbar.value), float(target_value), 0.05)  # Slower change
		
		await get_tree().create_timer(0.005).timeout

	player_healthbar.value = target_value


func _on_player_shooting_progress(progress):
	smooth_progress_update(primary_ability_overload.value, progress, 0.3)
	
	
func smooth_progress_update(start_value, target_value, duration):
	var steps = 50 
	var step_duration = duration / steps 
	var increment = (target_value - start_value) / steps 
	
	for i in range(steps):
		primary_ability_overload.value = start_value + increment * i
		await get_tree().create_timer(step_duration).timeout  
	primary_ability_overload.value = target_value


func _on_player_primary_ability_overloded(cooldown):
	cooldown_label.visible = true
	cooldown_label.text = cooldown
	cooldown_label_timer.start()

func _on_cooldown_label_timer_timeout():
	cooldown_label.visible = false
