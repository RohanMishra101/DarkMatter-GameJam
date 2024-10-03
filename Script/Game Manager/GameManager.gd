extends Node2D

var total_tablet_secured = 0
var world :PackedScene= preload("res://Scene/World/world.tscn")
var game_over_menu := preload("res://Scene/menu/game_over_screen.tscn")
var main_menu := preload("res://Scene/menu/menu.tscn")
var how_to_play := preload("res://Scene/how-to-play/how_to_play.tscn")
var enemy_1 = preload("res://Scene/enemy/enemy.tscn")
var player = null

var game_won = false
func _ready():
	pass

func _process(_delta):
	if total_tablet_secured == 6:
		print("GAME COMPLETED");
		_changeScene(game_over_menu)
		game_won = true
		set_process(false)

func _changeScene(stage_path):
	# Use call_deferred to safely change the scene
	call_deferred("_change_scene_deferred", stage_path)

func _change_scene_deferred(stage_path):
	var stage = stage_path.instantiate()
	get_tree().get_root().get_child(1).free()
	get_tree().get_root().add_child(stage)
