extends CharacterBody2D

@onready var power_selection = $CanvasLayer/PowerSelection

var speed:= 200.0
var is_attacking = false
var can_thukk := true
var super_power
var is_secondary_enable := false

var mouseDir

var punch_Distance

signal shoot_thukk(pos, mouse_angle)
signal is_mouse_enable(enable_mouse)
#signal secondary_weapon_shoot
func _ready():
	velocity = Vector2.ZERO
	connect_power_card()
	$"Heavy Punch".visible = false

func connect_power_card():
	var grid_container = $CanvasLayer/PowerSelection/GridContainer
	for power_card in grid_container.get_children():
		if power_card.has_signal("power_selected"):
			power_card.connect("power_selected", Callable(self, "on_power_card_selected"))

func on_power_card_selected(card_effect):
	$CanvasLayer/PowerSelection.visible = not $CanvasLayer/PowerSelection.visible
	is_secondary_enable = true
	super_power = card_effect
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
	
	handleMouseFunction()
	handlePathRotation()
	
	if Input.is_action_just_pressed("main_attack"):
		handle_attack()
	
	if is_secondary_enable and Input.is_action_just_pressed("secondary_attack"):
		#print("Weapon Attack Yet to implement")
		match super_power:
			"Heavy_Punch":
				#secondary_weapon_shoot.emit(secondary_weapond_shoot_distance,rad_to_deg(mouseDir.angle()))
				print("The effect of Heavy punch will be set here")
			"Teleport":
				print("Teleport Yet to implement")
			"super_speed":
				#Player spped is increased and bullet 
				#speed = 400
				print("super_speed Yet to implement")


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

#
func handlePathRotation():
	$"Heavy Punch".rotation_degrees = rad_to_deg(mouseDir.angle())
