extends CharacterBody2D

@onready var power_selection = $CanvasLayer/PowerSelection
@onready var secondary_weapon_cooldown = $secondary_weapon_cooldown
@onready var super_speed = $super_speed
@onready var overload_timer = $overload_timer
@onready var primary_ability_cooldown_timer = $primary_ability_cooldown_timer

var speed := 200.0
var max_health := 100
var current_health
var is_attacking = false
var can_thukk := true
var super_power
var is_secondary_enable := false
var thukkDmg := 20
var mouseDir
var punch_Distance
var knockback_strength := 300.0

#Primary ability 
var rapid_shoot_count = 0
var shoot_limit = 30
var is_overloaded = false
var max_overload_duration = 5.0
var overload_damage_range = [20, 40]

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
signal healthBarProgress(current_health,max_health)
signal shooting_progress(progress)
signal primary_ability_overloded(cooldown)
signal enable_enemy(enable)

var is_enemy_enable = false
func _ready():
	GameManager.player = self
	set_process(false)
	set_physics_process(false)
	handleMouseFunction()
	connect_power_card()
	current_health = max_health
	velocity = Vector2.ZERO
	$"Heavy Punch".visible = false
	overload_timer.one_shot = true
	overload_timer.wait_time = 1.5
	
	primary_ability_cooldown_timer.one_shot = true
	primary_ability_cooldown_timer.wait_time = max_overload_duration
	enable_enemy.emit(is_enemy_enable)
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
	is_enemy_enable = true
	set_timer.emit()
	$CanvasLayer/PowerSelection.visible = not $CanvasLayer/PowerSelection.visible
	$CanvasLayer/PowerSelection/CanvasLayer.visible = false
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
	#print("Shoot count : ", rapid_shoot_count)
	healthBarProgress.emit(current_health,max_health)
	#handle_cards_section()
	enable_enemy.emit(is_enemy_enable)
	mouseDir = get_mouse_direction()
	handlePathRotation()

	if Input.is_action_just_pressed("main_attack"):
		handle_attack()
		$bullet_sound.play()

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
	if current_health <= 0:
		die()
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
	if is_overloaded:
		return
	
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
	
	
	if not overload_timer.is_stopped():
		overload_timer.start() 
	else:
		overload_timer.start()
	
	rapid_shoot_count += 1
	
	if rapid_shoot_count <= shoot_limit:
		shooting_progress.emit(float(rapid_shoot_count) / shoot_limit * 100)
	if rapid_shoot_count >= shoot_limit:
		trigger_overload()
	

func trigger_overload():
	is_overloaded = true
	rapid_shoot_count = 0  
	shooting_progress.emit(100)
	primary_ability_cooldown_timer.start()  # Start cooldown before the player can shoot again

	# Apply health damage to the player
	var overload_damage = randi_range(overload_damage_range[0], overload_damage_range[1])
	apply_damage_to_player(overload_damage)
	primary_ability_overloded.emit("Primary Ability Disabled for 5sec")

	# Optionally, play a visual/audio cue for overload here
	#print("Shooting overload! Gun disabled for 5 seconds. Player health decreased by %d" % overload_damage)

#func handle_cards_section():
	#if Input.is_action_just_pressed("select_card"):
		#power_selection.visible = not power_selection.visible

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


func _on_overload_timer_timeout():
	rapid_shoot_count = 0
	shooting_progress.emit(0)
	
func _on_primary_ability_cooldown_timer_timeout():
	is_overloaded = false
	shooting_progress.emit(0)
	
func apply_damage_to_player(damage):
	current_health -= damage
	if current_health <= 0:
		current_health = 0
		print("Player is dead")


func hit(damage: int):
	current_health -= damage
	if current_health <= 0:
		die()

func die():
	print("You Died")
	GameManager._changeScene(GameManager.game_over_menu)
