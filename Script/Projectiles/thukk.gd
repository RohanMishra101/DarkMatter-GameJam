extends Area2D


@export var speed: = 500
var direction: Vector2
var damage = 10
var hit = 1
func _process(delta):
	position += direction * speed * delta

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_area_entered(_area):
	queue_free()
