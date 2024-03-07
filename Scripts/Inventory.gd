extends Sprite2D


# Called when the node enters the scene tree for the first time.
var children
var player
var popped = false
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func _physics_process(_delta):
	rotation -= .001
	
var turns
var alternate
func updatescore():
	if name == "turncount":
		var zeroscore = Global.playerinv[player].find(0)
		var emptyspot = get_parent().get_node(Global.colorint[zeroscore]).position
		get_tree().create_tween().tween_property(self, "position", emptyspot, 1).set_trans(Tween.TRANS_QUAD)
		if Global.turncount < 8:
			if not popped:
				get_tree().create_tween().tween_property(self, "scale", Vector2(1,1), 1).set_trans(Tween.TRANS_QUAD)
				for a in children:
					get_tree().create_tween().tween_property(a, "scale", Vector2(.05,.05), 1).set_trans(Tween.TRANS_QUAD)
				popped = true
			elif alternate:
				alternate = false
				turns += 1
			else: alternate = true
			for a in turns:
				get_tree().create_tween().tween_property(children[a], "scale", Vector2.ZERO, 1).set_trans(Tween.TRANS_QUAD)
		if Global.turncount == 8:
			popped = false
			get_tree().create_tween().tween_property(self, "scale", Vector2.ZERO, 1).set_trans(Tween.TRANS_QUAD)
			for a in children:
				get_tree().create_tween().tween_property(a, "scale", Vector2.ZERO, 1).set_trans(Tween.TRANS_QUAD)
	else:
		var score = Global.playerinv[player][Global.colorint.find(self.name)]
		if score > 0:
			if not popped:
				get_tree().create_tween().tween_property(self, "scale", Vector2(1,1), 1).set_trans(Tween.TRANS_QUAD)
				popped = true
			for a in score:
				get_tree().create_tween().tween_property(children[a], "scale", Vector2(1,1), 1).set_trans(Tween.TRANS_QUAD)
				children[a].play("Hover")

func reset():
	if get_parent().name == "player0":
		player = 0
		alternate = true
	else:
		player = 1
		alternate = false
	turns = 0
	children = get_children()
	popped = false
	get_tree().create_tween().tween_property(self, "scale", Vector2.ZERO, 1).set_trans(Tween.TRANS_QUAD)
	for a in children:
		get_tree().create_tween().tween_property(a, "scale", Vector2.ZERO, 1).set_trans(Tween.TRANS_QUAD)
