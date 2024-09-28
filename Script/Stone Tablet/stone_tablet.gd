extends Area2D

var hit_count := 0

signal tablet_secured(num)



func hit():
	if hit_count < 4:
		hit_count += 1
		
	if hit_count >= 4:
		if $Sprite2D.frame != 1:
			GameManager.total_tablet_secured += 1
			print(GameManager.total_tablet_secured)
		$Sprite2D.frame = 1
	else:
		$Sprite2D.frame = 0
		

func _on_area_entered(area):
	if area.is_in_group("Projectiles"):
		hit()
