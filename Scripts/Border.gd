extends Sprite2D
var purple = preload("res://Planets/planetpurple.tscn")
var red = preload("res://Planets/planetred.tscn")
var teal = preload("res://Planets/planetteal.tscn")
var blue = preload("res://Planets/planetblue.tscn")
var green = preload("res://Planets/planetgreen.tscn")
var grey = preload("res://Planets/planetgrey.tscn")
var orange = preload("res://Planets/planetorange.tscn")
var tweenlength = 5
func _ready():
	randomize()
	rotation_degrees = randf_range(0,360)
	var goodspot = Global.goodspot.duplicate()
	goodspot.shuffle()
	for a in 6:
		for b in 7:
			var temp = goodspot.pop_front()
			match a:
				0: 
					var orangeinst = orange.instantiate()
					orangeinst.position = temp
					add_child(orangeinst)
				1:
					var greyinst = grey.instantiate()
					greyinst.position = temp
					add_child(greyinst)
				2:
					var greeninst = green.instantiate()
					greeninst.position = temp
					add_child(greeninst)
				3:
					var blueinst = blue.instantiate()
					blueinst.position = temp
					add_child(blueinst)
				4:
					var tealinst = teal.instantiate()
					tealinst.position = temp
					add_child(tealinst)
				5:
					var redinst = red.instantiate()
					redinst.position = temp
					add_child(redinst)
	for a in 6:
		var temp = goodspot.pop_front()
		var purpleinst = purple.instantiate()
		purpleinst.position = temp
		add_child(purpleinst)

#To visualize goodspot
#	for a in goodspot.size():
#		var temp = goodspot.pop_front()
#		var purpleinst = purple.instantiate()
#		purpleinst.position = temp
#		add_child(purpleinst)

	scale = Vector2.ZERO
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(1,1), tweenlength).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(self.allset)
	tween.tween_callback(Global.updateinv)
	if Global.ai == 0:
		await get_tree().create_timer(tweenlength).timeout
		Global.aimove(0)

func allset():
	Global.allset = true

var rotating
func _physics_process(_delta):
	if rotating && allset:
		rotation += .0001
		
