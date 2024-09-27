@tool

extends Panel
@export var card_texture:Texture
@export var card_effect := ""

signal power_selected(card_effect)

func _ready():
	if card_texture:
		var stylebox = StyleBoxTexture.new()
		stylebox.texture = card_texture
		
		add_theme_stylebox_override("panel", stylebox)
	


func _on_button_pressed():
	print("A signal will be passed with the card effect : ", card_effect)
	power_selected.emit(card_effect)
