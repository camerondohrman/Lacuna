extends Area2D

func _ready():
	global_position = get_global_mouse_position()
	if Global.playerturn:
		get_node("altsprite").visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	var tween = get_tree().create_tween()
	tween.tween_property(self,"global_position",get_global_mouse_position(),.1)
	if Input.is_action_just_pressed("click"):
		var border = get_tree().get_root().get_node("Main").get_node("Border")
		if get_overlapping_areas():
			return
		elif Global.select2.legalplacement.get_collider() == self:
			var pawninstance = Global.pawnload.instantiate()
			pawninstance.set_position(position)
			if Global.playerturn: 
				pawninstance.get_node("altsprite").visible = true
				pawninstance.add_to_group("1")
			else: pawninstance.add_to_group("0")
			border.add_child(pawninstance)
			Global.changescore(Global.playerturn, Global.colorint.find(Global.select.color), 2)
			Global.passturn()
