extends CharacterBody2D

@onready var power_selection = $CanvasLayer/PowerSelection
@onready var secondary_weapon_cooldown = $secondary_weapon_cooldown
@onready var super_speed = $super_speed

var speed := 200.0
var is_attacking = false
var can_thukk := true
var super_power
var is_secondary_enable := false
var thukkDmg := 20
var mouseDir
var punch_Distance

# Teleportation radius
var min_radius = 250
var max_radius = 550

var on_cooldown = false
var cooldown_time = 0.0  # Variable to track the remaining cooldown time

signal shoot_thukk(pos, mouse_angle)
signal is_mouse_enable(enable_mouse)
signal set_timer()
signal ui_cooldown_time(cooldown_timer)
signal secondary_ui_icon(card_icon)
signal depricate_time(random_time)
signal accelerated_timer(times)
func _ready():
	set_process(false)
	set_physics_process(false)
	handleMouseFunction()
	velocity = Vector2.ZERO
	connect_power_card()
	$"Heavy Punch".visible = false

	# Connect the timer's timeout signal to a function to reset cooldown
	#secondary_weapon_cooldown.connect("timeout", self, "_on_secondary_weapon_cooldown_timeout")

func connect_power_card():
	var grid_container = $CanvasLayer/PowerSelection/GridContainer
	for power_card in grid_container.get_children():
		if power_card.has_signal("power_selected"):
			power_card.connect("power_selected", Callable(self, "on_power_card_selected"))

func on_power_card_selected(card_effect):
	set_process(true)
	set_physics_process(true)
	set_timer.emit()
	$CanvasLayer/PowerSelection.visible = not $CanvasLayer/PowerSelection.visible
	is_secondary_enable = true
	super_power = card_effect
	secondary_ui_icon.emit(card_effect)
	match card_effect:
		"Heavy_Punch":
			$"Heavy Punch".visible = not $"Heavy Punch".visible
		"Teleport":
			print("Teleport Yet to implement")
		"super_speed":
			print("super_speed Yet to implement")

func _process(_delta):
	handle_cards_section()
	mouseDir = get_mouse_direction()
	handlePathRotation()

	if Input.is_action_just_pressed("main_attack"):
		handle_attack()

	# Check and print the cooldown timer if it's active
	if on_cooldown:
		print_cooldown_timer(_delta)

	if is_secondary_enable and Input.is_action_just_pressed("secondary_attack"):
		match super_power:
			"Heavy_Punch":
				print("The effect of Heavy punch will be set here")
			"Teleport":
				if not on_cooldown:
					var randPos = get_random_pos()
					position = randPos
					var random_time = randf_range(30.0, 180.0)
					depricate_time.emit(random_time)
					start_cooldown(15)
				else:
					print("Teleport on cooldown, please wait.")
			"super_speed":
				if not on_cooldown:
					speed = 400.0
					thukkDmg = 50
					var speed_up_timer = randi_range(3,5)
					print(speed_up_timer)
					accelerated_timer.emit(speed_up_timer)
					super_speed.start(8)
					#Decrease Health as drawback from 20%-60%
					start_cooldown(30)
				print("YET TO IMPLEMENT")

func print_cooldown_timer(delta):
	# Decrease the cooldown time and print it
	if cooldown_time > 0:
		cooldown_time -= delta
		#print("Cooldown remaining: ", round(cooldown_time), " seconds")
		ui_cooldown_time.emit(int(cooldown_time))
	else:
		cooldown_time = 0  # Ensure it doesn't go below zero

func get_random_pos():
	var random_angle = randf() * TAU  # TAU is equal to 2 * PI
	var random_distance = randf_range(min_radius, max_radius)

	# Calculate the random position using the angle and distance
	var random_position = Vector2(
		cos(random_angle) * random_distance,
		sin(random_angle) * random_distance
	)
	return position + random_position

func _physics_process(_delta):
	handle_movement(_delta)

func handle_movement(_delta):
	var direction = Input.get_vector("left", "right", "up", "down")

	# Allow movement regardless of attack state
	velocity = direction

	if velocity.length() > 0:
		if not is_attacking:
			$AnimatedSprite2D.play("run")
		velocity = velocity.normalized() * speed
	else:
		if not is_attacking:
			$AnimatedSprite2D.play("idle")

	if direction.x > 0:
		$AnimatedSprite2D.flip_h = false
	elif direction.x < 0:
		$AnimatedSprite2D.flip_h = true

	move_and_slide()

func handle_attack():
	is_attacking = true
	mouseDir = get_mouse_direction()
	var thukk_position = $main_attack_marker/Marker2D.global_position
	shoot_thukk.emit(thukk_position, mouseDir)

	if velocity.length() > 0:
		$AnimatedSprite2D.play("running_main_attack")
	else:
		$AnimatedSprite2D.play("idle_main_attack")

	if not $AnimatedSprite2D.is_connected("animation_finished", Callable(self, "_on_attack_animation_finished")):
		$AnimatedSprite2D.connect("animation_finished", Callable(self, "_on_attack_animation_finished"))

func handle_cards_section():
	if Input.is_action_just_pressed("select_card"):
		power_selection.visible = not power_selection.visible

func _on_attack_animation_finished():
	is_attacking = false
	if $AnimatedSprite2D.is_connected("animation_finished", Callable(self, "_on_attack_animation_finished")):
		$AnimatedSprite2D.disconnect("animation_finished", Callable(self, "_on_attack_animation_finished"))

func get_mouse_direction():
	return (get_global_mouse_position() - position).normalized()

func handleMouseFunction():
	if $CanvasLayer/PowerSelection.visible:
		is_mouse_enable.emit(true)
	if not $CanvasLayer/PowerSelection.visible:
		is_mouse_enable.emit(false)

func handlePathRotation():
	$"Heavy Punch".rotation_degrees = rad_to_deg(mouseDir.angle())

func start_cooldown(timer):
	on_cooldown = true
	cooldown_time = timer  
	secondary_weapon_cooldown.start(timer)

func _on_secondary_weapon_cooldown_timeout():
	on_cooldown = false  # Reset cooldown flag
	cooldown_time = 0  # Reset cooldown time
	print("Ability is ready to use again!")


func _on_super_speed_timeout():
	speed = 200
	thukkDmg = 20
	print("Super Speed Back to normal")
