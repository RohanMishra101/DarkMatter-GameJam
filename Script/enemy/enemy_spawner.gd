extends Node2D

@export var spawn_distance := 500.0
@onready var spawner_timer = $spawner_timer

var playerPos
var spawnPosition
var spawn_wait_time = 2.0
var min_spawn_wait_time = 0.5
var spawn_rate_decrease = 0.1
var random_spawn_variation = 0.2

signal spawn_enemy(spawn_position)

func _ready():
	spawner_timer.wait_time = spawn_wait_time
	spawner_timer.start()

func _process(_delta):
	if GameManager.player != null:
		playerPos = GameManager.player.global_position

func get_random_spawn_position() -> Vector2:
	var angle = randf() * PI * 2
	var enemy_position = playerPos + Vector2(cos(angle), sin(angle)) * spawn_distance
	return enemy_position

func _on_spawner_timer_timeout():
	spawnPosition = get_random_spawn_position()
	spawn_enemy.emit(spawnPosition)
	spawn_wait_time = max(spawn_wait_time - spawn_rate_decrease, min_spawn_wait_time)
	var random_adjustment = randf_range(-random_spawn_variation, random_spawn_variation)
	spawner_timer.wait_time = spawn_wait_time + random_adjustment
	spawner_timer.start()
