extends Node2D

var total_tablet_secured := 0

func _ready():
	pass


func _process(delta):
	if total_tablet_secured == 2:
		print("GAME COMPLETED");
		set_process(false)
