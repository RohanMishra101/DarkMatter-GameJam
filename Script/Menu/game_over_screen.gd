extends Control

@onready var label = $MarginContainer/CanvasLayer/Label
@onready var game_over_sound = $"game over sound"

func _ready():
	game_over_sound.play()

func _process(delta):
	if GameManager.game_won:
		label.text = "YOU WIN!!"
	else:
		label.text = "GAME OVER!!"

func _on_play_again_pressed():
	GameManager._changeScene(GameManager.world)


func _on_main_menu_pressed():
	GameManager._changeScene(GameManager.main_menu)

func _on_exit_pressed():
	get_tree().quit()
