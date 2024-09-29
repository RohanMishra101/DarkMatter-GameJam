extends Node2D

var total_tablet_secured := 0
var world :PackedScene= preload("res://Scene/World/world.tscn")
func _ready():
	pass

func _process(_delta):
	if total_tablet_secured == 2:
		print("GAME COMPLETED");
		set_process(false)

func _changeScene(stage_path):
	# Use call_deferred to safely change the scene
	call_deferred("_change_scene_deferred", stage_path)

func _change_scene_deferred(stage_path):
	var stage = stage_path.instantiate()
	get_tree().get_root().get_child(1).free()
	get_tree().get_root().add_child(stage)
