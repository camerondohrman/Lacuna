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
var weightofcolordesire = 0
var weightofspreadingout = .25
var weightofavoidingopponent = .25
var response = 0
var awaitingresponse = false
func aiturn(step):
	match step:
		0:
			allset = false
			var function = [.25,.5,.75,1,0,0,0,0]
			spotscore.resize(goodspot.size())
			spotscore.fill(0)
			colordesire.clear()
			for a in 7:
				colordesire.append(function[playerinv[0][a]]*function[playerinv[1][a]])
				var planetsofthiscolor = get_tree().get_nodes_in_group(colorint[a])
				for b in goodspot.size():
					for c in planetsofthiscolor:
						spotscore[b] += ((925-(goodspot[b].distance_to(c.position)))/925)*colordesire[a]
			for a in goodspot.size():
				if playerturn:
					for b in get_tree().get_nodes_in_group("1"):
						spotscore[a] = spotscore[a]*(goodspot[a].distance_to(b.position)/925)*weightofspreadingout
					for b in get_tree().get_nodes_in_group("0"):
						spotscore[a] = spotscore[a]*(goodspot[a].distance_to(b.position)/925)*weightofavoidingopponent
				else:
					for b in get_tree().get_nodes_in_group("0"):
						spotscore[a] = spotscore[a]*(goodspot[a].distance_to(b.position)/925)*weightofspreadingout
					for b in get_tree().get_nodes_in_group("1"):
						spotscore[a] = spotscore[a]*(goodspot[a].distance_to(b.position)/925)*weightofavoidingopponent
			aiturn(1)
		1:
			var consideredcolors = []
			var consideredplanets = []
			maxdesire = colordesire.max()
			if maxdesire == 0:
				setup()
			for a in colordesire.size():
				if colordesire[a] + weightofcolordesire >= maxdesire:
					consideredcolors.append(a)
					colordesire[a] = 0
			for a in consideredcolors:
				consideredplanets.append_array(get_tree().get_nodes_in_group(colorint[a]))
			for a in consideredplanets:
				a.updateconnections = true
				a.aipotential = true
				response += 1
			inqueue.append("aiturn_2")
		2:
			potentialmoves = get_tree().get_nodes_in_group("valid")
			if potentialmoves.size() == 0:
				aiturn(1)
				return
			elif potentialmoves.size() == 1:
				select = potentialmoves[0].connection[0]
				select2 = potentialmoves[0].connection[1]
				aiplacement = potentialmoves[0].position
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
			var pawninstance = pawnload.instantiate()
			pawninstance.scale = Vector2.ZERO
			border.add_child(pawninstance)
			var tween = get_tree().create_tween()
			if playerturn: 
				pawninstance.get_node("altsprite").visible = true
				pawninstance.add_to_group("1")
			else: pawninstance.add_to_group("0")
			tween.parallel().tween_property(pawninstance, "scale", Vector2(1,1), 1)
			tween.parallel().tween_property(pawninstance, "position", aiplacement, 1)
			changescore(playerturn, colorint.find(select.color), 2)
			await get_tree().create_timer(1).timeout
			deletegroup("ai")
			allset = true
			passturn()

func changescore(player, color, amount):
	playerinv[player][color] += amount
	if playerinv[player][color] > 4:
		playerinv[player][color] = 4

func getcolor(planet):
	var color
	var groups = planet.get_groups()
	for a in groups:
		if colorint.has(a):
			color = a
	return color

var ai = 1
func passturn():
	#Update inventory
	updateinv()
	#Delete selected planents
	if select && select2:
		for a in 2:
			border.add_child(deleteload.instantiate())
	if select:
		select.free()
	if select2:
		select2.free()
	deselect()
	#Advance turn count
	turncount += 1
	if turncount == 8:
		endgame()
	#Pass turn to next player or ai
	if playerturn:
		playerturn = 0
	else:
		playerturn = 1
	if playerturn == ai:
		aiturn(0)

func endgame():
	allset = false
	var transition
	if turncount == 8:
		for a in colorint:
			var planets = get_tree().get_nodes_in_group(a)
			for b in planets:
				b.endgame()
			if planets:
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
		var winnerpawns
		if playerscore[0]>playerscore[1]:
			winner = 0
			winnerpawns = get_tree().get_nodes_in_group("0")
		else:
			winner = 1
			winnerpawns = get_tree().get_nodes_in_group("1")
		transition = winnerpawns[0]
	else:
		var aipawns
		if ai == 0:
			aipawns = get_tree().get_nodes_in_group("0")
			if aipawns.size() == 0:
				winner = 0
				transition = pawnload.instantiate()
				transition.find_child("Sprite2D").scale = Vector2.ZERO
				transition.name = "transition"
				border.add_child(transition)
				aipawns.append(border.get_node("transition"))
		else:
			aipawns = get_tree().get_nodes_in_group("1")
			if aipawns.size() == 0:
				winner = 1
				transition = pawnload.instantiate()
				transition.find_child("altsprite").visible = true
				transition.find_child("altsprite").scale = Vector2.ZERO
				transition.find_child("Sprite2D").scale = Vector2.ZERO
				transition.name = "transition"
				border.add_child(transition)
				aipawns.append(border.get_node("transition"))
		transition = aipawns[0]
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
func _ready():
	cancel = get_tree().get_root().get_node("Main").get_node("Cancel")
	roundend = get_tree().get_root().get_node("Main").get_node("Round End")
	inventories = get_tree().get_nodes_in_group("inventory")
	buildgoodspot()
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
	border.rotating = true

var inqueue = []
func awaitdictionary(function):
	match function:
		"aiturn_2": aiturn(2)

var paused = false
func _process(_delta):
	#Handles await dictionary
	if inqueue.size()>0:
		print(response)
		if response == 0:
			for a in inqueue:
				awaitdictionary(inqueue.pop_front())
	##Below handles player input
	if not allset:
		return
	if select:
		border.rotating = false
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
	border.rotating = true
	select = null
	select2 = null
	placing = false
	connected.clear()
	deletegroup("legalplacement")
	deletegroup("placement")
	deletegroup("potential")


var goodspot = []
func buildgoodspot():
	var x = 60
	var y = round(sqrt(x*x+(x/2)*(x/2)))
	var d = 925
	var tempx
	var tempy
	var intervalx = round(d/x)+1
	var intervaly = round(d/y)+1
	var alternate = false
	for a in intervalx:
		tempx = (a*x)-(d/2)
		if alternate: alternate = false
		else: alternate = true
		for b in intervaly:
			if alternate:
				tempy = (b*y)-(d/2)
			else:
				tempy = (b*y)-(d/2)+(y/2)
			goodspot.append(Vector2(tempx,tempy))
	var remove = []
	for a in goodspot.size():
		if sqrt(goodspot[a].x*goodspot[a].x+goodspot[a].y*goodspot[a].y) > d/2:
			remove.append(goodspot[a])
	for a in remove:
		goodspot.erase(a)
