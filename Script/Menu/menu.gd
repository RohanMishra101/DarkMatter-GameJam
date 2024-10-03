extends Control




func _on_play_btn_pressed():
	GameManager._changeScene(GameManager.world)


func _on_how_btn_pressed():
	GameManager._changeScene(GameManager.how_to_play)


func _on_exit_btn_pressed():
	get_tree().quit()
