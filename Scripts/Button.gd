extends Button

func _on_pressed():
	if Global.allset:
		match name:
			"quit": get_tree().quit()
			"endgame": Global.endgame()
