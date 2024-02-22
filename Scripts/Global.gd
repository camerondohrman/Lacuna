extends Node

var allset = false
var select
var select2
var deleteload = preload("res://Delete.tscn")
var borderload = preload("res://Border.tscn")
var pawnload = preload("res://Pawn.tscn")
var deletelocation = false
var placing = false
var connected = []
var playerturn = 0
var turncount = 0
var inventories
var playerinv = [[1,0,0,0,0,0,0],[0,0,0,0,0,0,0]]
var colorint = ["purple", "orange","blue", "green","red","grey","teal"]
var border
var winner

var potentialmoves
var colordesire = []
var spotscore = []
var aiplacement
var maxdesire
var weightofcolordesire = .25
var weightofspreadingout = .25
func aiturn(step):
	match step:
		0:
			var function = [.25,.5,.75,1,0,0,0,0]
			spotscore.resize(goodspot.size())
			spotscore.fill(0)
			colordesire.clear()
			for a in 7:
				colordesire.append(function[playerinv[0][a]]*function[playerinv[1][a]])
				var flowersofthiscolor = get_tree().get_nodes_in_group(colorint[a])
				for b in goodspot.size():
					for c in flowersofthiscolor:
						spotscore[b] += ((900-(goodspot[b].distance_to(c.position)))/900)*colordesire[a]
			for a in goodspot.size():
				for b in get_tree().get_nodes_in_group("1"):
					spotscore[a] = spotscore[a]*(goodspot[a].distance_to(b.position)/900)*weightofspreadingout
			aiturn(1)
		1:
			var consideredcolors = []
			var consideredflowers = []
			maxdesire = colordesire.max()
			if maxdesire == 0:
				setup()
			for a in colordesire.size():
				if colordesire[a] + weightofcolordesire > maxdesire:
					consideredcolors.append(a)
					colordesire[a] = 0
			for a in consideredcolors:
				consideredflowers.append_array(get_tree().get_nodes_in_group(colorint[a]))
			for a in consideredflowers:
				a.updateconnections = true
				a.aipotential = true
			await get_tree().create_timer(1).timeout
			potentialmoves = get_tree().get_nodes_in_group("valid")
			if potentialmoves.size() == 0:
				aiturn(1)
			elif potentialmoves.size() == 1:
				select = potentialmoves[0].connection[0]
				select2 = potentialmoves[0].connection[1]
				aiplacement = potentialmoves[0].position
				aiturn(3)
			else:
				var closest
				var closestdistance = INF
				for a in potentialmoves:
					var distance = a.position.distance_to(goodspot[spotscore.find(spotscore.max())])
					if distance < closestdistance:
						closest = a
						closestdistance = distance
				select = closest.connection[0]
				select2 = closest.connection[1]
				aiplacement = closest.position
				aiturn(3)
		3:
			var pawninstance = pawnload.instantiate()
			pawninstance.scale = Vector2.ZERO
			var tween = get_tree().create_tween()
			if playerturn: 
				pawninstance.get_node("altsprite").visible = true
				pawninstance.add_to_group("1")
			else: pawninstance.add_to_group("0")
			border.add_child(pawninstance)
			tween.parallel().tween_property(pawninstance, "scale", Vector2(1,1), 1)
			tween.parallel().tween_property(pawninstance, "position", aiplacement, 1)
			changescore(playerturn, colorint.find(select.color), 2)
			await get_tree().create_timer(1).timeout
			deletegroup("ai")
			passturn()


func changescore(player, color, amount):
	playerinv[player][color] += amount
	if playerinv[player][color] > 4:
		playerinv[player][color] = 4

func getcolor(flower):
	var color
	var groups = flower.get_groups()
	for a in groups:
		if colorint.has(a):
			color = a
	return color
	
func passturn():
	updateinv()
	if playerturn:
		playerturn = 0
	else:
		playerturn = 1
		aiturn(0)
	if select && select2:
		for a in 2:
			border.add_child(deleteload.instantiate())
	if select:
		select.free()
	if select2:
		select2.free()
	deselect()
	turncount += 1
	if turncount == 8:
		allset = false
		for a in colorint:
			var flowers = get_tree().get_nodes_in_group(a)
			for b in flowers:
				b.endgame()
			if flowers:
				await get_tree().create_timer(2).timeout
				updateinv()
				await get_tree().create_timer(1).timeout
		var playerscore = [0,0]
		for a in playerinv[0]:
			if a == 4:
				playerscore[0] += 1
		for a in playerinv[1]:
			if a == 4:
				playerscore[1] += 1
		var transition
		if playerscore[0]>playerscore[1]:
			winner = 0
			var player0pawns = get_tree().get_nodes_in_group("0")
			transition = player0pawns[0]
		else:
			winner = 1
			var player1pawns = get_tree().get_nodes_in_group("1")
			transition = player1pawns[0]
		transition.z_index = 10
		var tween = get_tree().create_tween()
		roundend.play()
		tween.parallel().tween_property(transition.find_child("altsprite"), "scale", Vector2(1,1), 5)
		tween.parallel().tween_property(transition.find_child("Sprite2D"), "scale", Vector2(1,1), 5)
		tween.parallel().tween_property(transition, "position", Vector2.ZERO, 5)
		tween.parallel().tween_property(transition, "rotation", -border.rotation, 5)
		tween.tween_callback(Global.setup)

var cancel
var roundend
##lol
var goodspot = [Vector2(-400,-220),
Vector2(-380,-100),
Vector2(-380,-20),
Vector2(-360,180),
Vector2(-360,260),
Vector2(-340,-260),
Vector2(-340,-180),
Vector2(-320,20),
Vector2(-320,100),
Vector2(-300,-340),
Vector2(-280,-140),
Vector2(-280,-60),
Vector2(-260,380),
Vector2(-260,300),
Vector2(-240,-220),
Vector2(-220,220),
Vector2(-220,140),
Vector2(-200,-380),
Vector2(-180,60),
Vector2(-180,-20),
Vector2(-160,280),
Vector2(-140,-100),
Vector2(-140,-180),
Vector2(-120,120),
Vector2(-120,400),
Vector2(-100,-260),
Vector2(-100,-340),
Vector2(-80,-40),
Vector2(-80,240),
Vector2(-80,320),
Vector2(-60,-420),
Vector2(-40,80),
Vector2(-40,-200),
Vector2(-40,160),
Vector2(0,0),
Vector2(0,-80),
Vector2(0,440),
Vector2(0,-360),
Vector2(0,360),
Vector2(40,-240),
Vector2(40,-160),
Vector2(40,280),
Vector2(40,200),
Vector2(80,120),
Vector2(80,-320),
Vector2(80,-400),
Vector2(80,40),
Vector2(100,340),
Vector2(120,-120),
Vector2(140,-40),
Vector2(140,180),
Vector2(160,-200),
Vector2(160,-280),
Vector2(180,-360),
Vector2(180,380),
Vector2(180,300),
Vector2(200,20),
Vector2(220,-140),
Vector2(220,220),
Vector2(220,140),
Vector2(240,-300),
Vector2(260,-380),
Vector2(280,340),
Vector2(280,60),
Vector2(280,-20),
Vector2(280,260),
Vector2(300,-100),
Vector2(300,-180),
Vector2(320,-260),
Vector2(340,180),
Vector2(340,100),
Vector2(380,260),
Vector2(400,200),
Vector2(400,-140),
Vector2(400,-60)]
func _ready():
	cancel = get_tree().get_root().get_node("Main").get_node("Cancel")
	roundend = get_tree().get_root().get_node("Main").get_node("Round End")
	inventories = get_tree().get_nodes_in_group("inventory")
	setup()

func updateinv():
	for a in inventories:
		a.updatescore()

var prevborder
var winsprite
func setup():
	if winsprite:
		winsprite.visible = false
	if border:
		if winner:
			winsprite = get_tree().get_root().get_node("Main").get_node("Player1Pawn")
			winsprite.visible = true
		else: 
			winsprite = get_tree().get_root().get_node("Main").get_node("Player2Pawn")
			winsprite.visible = true
		border.free()
	get_tree().get_root().get_node("Main").add_child(borderload.instantiate())
	border = get_tree().get_root().get_node("Main").get_node("Border")
	for a in inventories:
		a.reset()
	playerinv = [[1,0,0,0,0,0,0],[0,0,0,0,0,0,0]]
	turncount = 0

var paused = false
func _process(_delta):
	if select:
		if Input.is_action_just_pressed("rightclick"):
			cancel.play()
			deselect()
	if Input.is_action_just_pressed("escape"):
		cancel.play()
		if not paused:
			paused = true
			var tween = get_tree().create_tween()
			var menu = get_tree().get_root().get_node("Main").find_child("PauseMenu")
			tween.tween_property(menu, "scale", Vector2(.5,.5),1).set_trans(Tween.TRANS_QUAD)
		elif paused:
			paused = false
			var tween = get_tree().create_tween()
			var menu = get_tree().get_root().get_node("Main").find_child("PauseMenu")
			tween.tween_property(menu, "scale", Vector2(1,1),1).set_trans(Tween.TRANS_QUAD)

func deletegroup(string):
	var delete = get_tree().get_nodes_in_group(string)
	for a in delete:
		a.free()

func deselect():
	select = null
	select2 = null
	placing = false
	connected.clear()
	deletegroup("legalplacement")
	deletegroup("placement")
	deletegroup("potential")
