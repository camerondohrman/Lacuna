extends AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	if Global.deletelocation:
		position = Global.select.position
		frame = Global.colorint.find(Global.select.color)
		Global.deletelocation = false
	else:
		position = Global.select2.position
		frame = Global.colorint.find(Global.select2.color)
		Global.deletelocation = true
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 1).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(self.queue_free)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
