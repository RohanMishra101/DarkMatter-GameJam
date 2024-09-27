extends Node2D

var thukk_scene = preload("res://Scene/Projectiles/thukk.tscn")

var max_distance = 100

var player_pos
var custom_cursor: Sprite2D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	custom_cursor = $CustomCursorSprite

func _process(delta):
	player_pos = $Player.position
	var mouse_position = get_global_mouse_position()
	var direction = mouse_position - player_pos
	
	var distance = direction.length()
	if distance >  max_distance:
		direction = direction.normalized() * max_distance
		
	custom_cursor.position = player_pos + direction

func _on_player_shoot_thukk(pos,mouse_angle):
	var thukk = thukk_scene.instantiate() as Area2D
	thukk.position = pos
	thukk.rotation_degrees = rad_to_deg(mouse_angle.angle())
	thukk.direction = mouse_angle
	$Projectiles.add_child(thukk)
