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
	
func updatescore():
	children = get_children()
	if get_parent().name == "player0": player = 0
	else: player = 1
	var score = Global.playerinv[player][Global.colorint.find(self.name)]
	if score > 0:
		if not popped:
			get_tree().create_tween().tween_property(self, "scale", Vector2(1,1), 1).set_trans(Tween.TRANS_QUAD)
			popped = true
		for a in score:
			get_tree().create_tween().tween_property(children[a], "scale", Vector2(1,1), 1).set_trans(Tween.TRANS_QUAD)
			children[a].play("Hover")

func reset():
	children = get_children()
	popped = false
	get_tree().create_tween().tween_property(self, "scale", Vector2.ZERO, 1).set_trans(Tween.TRANS_QUAD)
	for a in children:
		get_tree().create_tween().tween_property(a, "scale", Vector2.ZERO, 1).set_trans(Tween.TRANS_QUAD)
