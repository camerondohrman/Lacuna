extends Button

func _on_pressed():
	if name == "quit":
		get_tree().quit()
	elif Global.allset == true:
		match name:
			"endgame": Global.endgame()
			"switchai":
				Global.switchai()
				for a in get_children():
					a.visible = false
				match Global.nextai:
					0: get_node("0").visible = true
					1: get_node("1").visible = true
					2: get_node("2").visible = true
