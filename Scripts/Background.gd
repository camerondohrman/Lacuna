extends AnimatedSprite2D

func _process(delta):
	var temp = round(get_global_mouse_position()[0]/(1920/15))
	if range(15).has(temp):
		frame = temp
	
