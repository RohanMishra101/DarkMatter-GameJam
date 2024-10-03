extends AnimatedSprite2D

@export var HEALTH := 40
@export var DAMAGE := 20
@export var speed:=100.0
@onready var enemy = $"."

var velocity = Vector2()
@onready var stun_timer = $Stun_Timer

signal died
var stun:=false
var knockback := 3
func _physics_process(delta):
	if GameManager.player != null and stun == false:
		velocity = global_position.direction_to(GameManager.player.global_position)
		play("run")
	elif stun:
		velocity = lerp(velocity,Vector2(0,0),0.1)
	global_position += velocity * speed * delta
	
	if HEALTH <= 0:
		emit_signal("died")
		enemy.queue_free()
	
func hit(damage):
	if stun == false:
		HEALTH -= damage
		enemy.play("Stun")
		velocity = -velocity * knockback
		stun = true
		stun_timer.start()

func _on_hitbox_area_entered(area):
	if area.is_in_group("Player_Hitbox"):
		var parent = area.get_parent()
		if parent.has_method("hit"):
			parent.hit(DAMAGE)

func _on_stun_timer_timeout():
	enemy.play("run")
	stun = false
