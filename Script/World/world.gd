extends Node2D

@onready var enemy_spawner = $"Enemy Spawner"
@onready var audio_stream_player = $AudioStreamPlayer

var thukk_scene = preload("res://Scene/Projectiles/thukk.tscn")

var max_distance = 100

var player_pos
var custom_cursor: Sprite2D

var is_mouse_visible := false
#signal distance_from_player_to_cursor(distance)
var enemy
var can_enemy_spawn
func _ready():
	custom_cursor = $CustomCursorSprite
	audio_stream_player.play()
	GameManager.total_tablet_secured = 0

func _process(_delta):
	if not is_mouse_visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		player_pos = $Player.position
		var mouse_position = get_global_mouse_position()
		var direction = mouse_position - player_pos
	
		var distance = direction.length()
		if distance >  max_distance:
			direction = direction.normalized() * max_distance
			
		#distance_from_player_to_cursor.emit(distance)
		
		custom_cursor.visible = true
		custom_cursor.position = player_pos + direction
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		custom_cursor.visible = false
	

func _on_player_shoot_thukk(pos,mouse_angle):
	var thukk = thukk_scene.instantiate() as Area2D
	thukk.position = pos
	thukk.rotation_degrees = rad_to_deg(mouse_angle.angle())
	thukk.direction = mouse_angle
	$Projectiles.add_child(thukk)


func _on_player_is_mouse_enable(enable_mouse):
	is_mouse_visible = enable_mouse


func _on_enemy_spawner_spawn_enemy(spawn_position):
	if can_enemy_spawn:
		enemy = GameManager.enemy_1.instantiate()
		enemy.position = spawn_position
		#print("New Enemy Spawned at",spawn_position)
		enemy_spawner.add_child(enemy)
		enemy.connect("died", Callable(self, "_on_enemy_died"))

func _on_player_enable_enemy(enable):
	can_enemy_spawn = enable
