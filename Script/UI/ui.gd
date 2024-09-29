extends Control

@onready var timer_label = $MarginContainer/CanvasLayer/TimerBox/TimerLabel
@onready var icon = $MarginContainer/CanvasLayer/Abilities/icon
@onready var cooldown = $MarginContainer/CanvasLayer/Abilities/icon/cooldown
@onready var reduced_time = $MarginContainer/CanvasLayer/ReducedTimer/reduced_time
@onready var times = $MarginContainer/CanvasLayer/accelerated_time/times

var teleport_icon = preload("res://Assets/Icon/portal_icon.png")

var total_time = 14 * 60 + 59  # Total time (in seconds)
var time_left = total_time      # Remaining time (in seconds)
var time_multiplier = 1         # Timer speed multiplier

func _ready():
	icon.visible = false
	cooldown.visible = false
	reduced_time.visible = false
	times.visible = false
	update_timer_label()

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
			print("YET TO IMPLEMENT!!")
		"Teleport":
			icon.texture = teleport_icon
		"super_speed":
			print("YET TO IMPLEMENT!!")

func _on_player_depricate_time(random_time):
	display_reduced_time(random_time)
	time_left -= random_time

	if time_left < 0:
		time_left = 0

	update_timer_label()

	if time_left <= 0:
		print("GAME OVER!!")

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
