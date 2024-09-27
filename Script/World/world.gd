extends Node2D

var thukk_scene = preload("res://Scene/Projectiles/thukk.tscn")

func _on_player_shoot_thukk(pos,mouse_angle):
	var thukk = thukk_scene.instantiate() as Area2D
	thukk.position = pos
	thukk.rotation_degrees = rad_to_deg(mouse_angle.angle())
	thukk.direction = mouse_angle
	$Projectiles.add_child(thukk)
