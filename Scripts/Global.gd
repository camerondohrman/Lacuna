extends Node

#Bool that prevents player input
var allset = false
#Two nodes that will be deleted by passturn
var select
var select2
#Node that is instantiated by passturn
var deleteload = preload("res://Delete.tscn")
#Game board node
var borderload = preload("res://Border.tscn")
#Player pawn node
var pawnload = preload("res://Pawn.tscn")
var placing = false
var connected = []
var playerturn = 0
var turncount = 0
var inventories
var playerinv = [[1,0,0,0,0,0,0],[0,0,0,0,0,0,0]]
var colorint = ["purple", "orange","blue", "green","red","grey","teal"]
var border
var winner
var response = 0
var aiplacement

var cancel
var roundend
func _ready():
	cancel = get_tree().get_root().get_node("Main").get_node("Cancel")
	roundend = get_tree().get_root().get_node("Main").get_node("Round End")
	inventories = get_tree().get_nodes_in_group("inventory")
	buildgoodspot()
	setup()

var paused = false
func _process(_delta):
	#Handles await dictionary
	if inqueue.size()>0:
		if response == 0:
			for a in inqueue:
				awaitdictionary(inqueue.pop_front())
	#Below handles player input
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
	#Allset prevents player input excepting the escape key and the quit button
	if not allset:
		return
	if select:
		border.rotating = false
		if Input.is_action_just_pressed("rightclick"):
			if select:
				select.selectcircle(false)
			cancel.play()
			deselect()

var threshold
var search
var movescore
var movescorecount
var movescorecountmax
func aimove(step):
	var planets = get_tree().get_nodes_in_group("planet")
	var potentialmoves = get_tree().get_nodes_in_group("valid")
	match step:
		0: 
			allset = false
			for a in planets:
				a.updateconnections = true
				a.aipotential = true
				response += 1
			inqueue.append("aimove_1")
		1: 
			if potentialmoves.size() == 0:
				print("Unhandled exception: no moves found")
				get_tree().quit()
			else:
				movescore = []
				var playerpawns = [[],[]]
				playerpawns[0] = get_tree().get_nodes_in_group("0")
				playerpawns[1] = get_tree().get_nodes_in_group("1")
				for a in potentialmoves:
					playerpawns[ai].append(a)
					var tempscore = playerinv[ai].duplicate()
					tempscore[colorint.find(getcolor(a.connection[0]))] += 2
					for b in planets:
						if not a.connection.has(b):
							var closestpair = []
							closestpair.resize(2)
							for c in 2:
								var closestdistance = INF
								for d in playerpawns[c]:
									var distance
									if playerpawns[c].size() == 0:
										distance = b.position.distance_to(Vector2.ZERO)
										closestdistance = distance
									else:
										distance = b.position.distance_to(d.position)
										if distance < closestdistance:
											closestdistance = distance
									closestpair[c] = closestdistance
							if closestpair.find(closestpair.min()) == ai:
								tempscore[colorint.find(getcolor(b))] += 1
					playerpawns[ai].erase(a)
					movescore.append(tempscore)
				for a in movescore.size():
					for b in 7:
						if playerinv[0][b] == 4 || playerinv[1][b] == 4:
							movescore[a][b] = 0
				threshold = 4
				search = 0
				aimove(3)
		3:
			var bestmove
			if search == 4:
				bestmove = potentialmoves[movescorecount.find(movescorecountmax)]
			else:
				movescorecount = []
				for a in movescore:
					var count = 0
					for b in a:
						if b >= threshold:
							count += 1
					movescorecount.append(count)
				movescorecountmax = movescorecount.max()
				if movescorecountmax == 0:
					search += 1
					threshold -= 1
					aimove(3)
					return
				var temp = 0
				for a in movescorecount:
					if a == movescorecountmax:
						temp += 1
				if temp == 1:
					bestmove = potentialmoves[movescorecount.find(movescorecountmax)]
				else:
					search += 1
					threshold += 1
					for a in movescorecount.size():
						if movescorecount[a] < movescorecountmax:
							movescore[a] = [0,0,0,0,0,0,0]
					aimove(3)
					return
			aiplacement = bestmove.position
			select = bestmove.connection[0]
			select2 = bestmove.connection[1]
			aimove(4)
		4:
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
			passturn()

#var potentialmoves
#var colordesire = []
#var spotscore = []
#var maxdesire
#var weightofcolordesire = 0.5
#var weightofspreadingout = 0.5
#var weightofavoidingopponent = 0.5
#var awaitingresponse = false
#func aiturn(step):
#	match step:
#		0: 
#			allset = false
#			var function = [0.25, 0.5, 0.75, 1, 0]
#			spotscore.resize(goodspot.size())
#			spotscore.fill(0)
#			colordesire.clear()
#			for a in 7:
#				colordesire.append(function[playerinv[0][a]]*function[playerinv[1][a]])
#				var planetsofthiscolor = get_tree().get_nodes_in_group(colorint[a])
#				for b in goodspot.size():
#					for c in planetsofthiscolor:
#						spotscore[b] += ((925-(goodspot[b].distance_to(c.position)))/925)*colordesire[a]
#			for a in goodspot.size():
#				if playerturn:
#					for b in get_tree().get_nodes_in_group("1"):
#						spotscore[a] = spotscore[a]*(goodspot[a].distance_to(b.position)/925)*weightofspreadingout
#					for b in get_tree().get_nodes_in_group("0"):
#						spotscore[a] = spotscore[a]*(goodspot[a].distance_to(b.position)/925)*weightofavoidingopponent
#				else:
#					for b in get_tree().get_nodes_in_group("0"):
#						spotscore[a] = spotscore[a]*(goodspot[a].distance_to(b.position)/925)*weightofspreadingout
#					for b in get_tree().get_nodes_in_group("1"):
#						spotscore[a] = spotscore[a]*(goodspot[a].distance_to(b.position)/925)*weightofavoidingopponent
#			aiturn(1)
#		1:
#			var consideredcolors = []
#			var consideredplanets = []
#			maxdesire = colordesire.max()
#			if maxdesire == 0:
#				setup()
#			for a in colordesire.size():
#				if colordesire[a] + weightofcolordesire >= maxdesire:
#					consideredcolors.append(a)
#					colordesire[a] = 0
#			for a in consideredcolors:
#				consideredplanets.append_array(get_tree().get_nodes_in_group(colorint[a]))
#			for a in consideredplanets:
#				a.updateconnections = true
#				a.aipotential = true
#				response += 1
#			inqueue.append("aiturn_2")
#		2:
#			potentialmoves = get_tree().get_nodes_in_group("valid")
#			if potentialmoves.size() == 0:
#				aiturn(1)
#				return
#			elif potentialmoves.size() == 1:
#				select = potentialmoves[0].connection[0]
#				select2 = potentialmoves[0].connection[1]
#				aiplacement = potentialmoves[0].position
#			else:
#				var closest
#				var closestdistance = INF
#				for a in potentialmoves:
#					var distance = a.position.distance_to(goodspot[spotscore.find(spotscore.max())])
#					if distance < closestdistance:
#						closest = a
#						closestdistance = distance
#				select = closest.connection[0]
#				select2 = closest.connection[1]
#				aiplacement = closest.position
#			var pawninstance = pawnload.instantiate()
#			pawninstance.scale = Vector2.ZERO
#			border.add_child(pawninstance)
#			var tween = get_tree().create_tween()
#			if playerturn: 
#				pawninstance.get_node("altsprite").visible = true
#				pawninstance.add_to_group("1")
#			else: pawninstance.add_to_group("0")
#			tween.parallel().tween_property(pawninstance, "scale", Vector2(1,1), 1)
#			tween.parallel().tween_property(pawninstance, "position", aiplacement, 1)
#			changescore(playerturn, colorint.find(select.color), 2)
#			await get_tree().create_timer(1).timeout
#			deletegroup("ai")
#			passturn()

#Changes player inventory,checks that the inventory doesn't exceed 4
func changescore(player, color, amount):
	playerinv[player][color] += amount
	if playerinv[player][color] > 4:
		playerinv[player][color] = 4

#Returns the color of the planet, specifically it returns a group of the node that appears on the color list
func getcolor(planet):
	var color
	var groups = planet.get_groups()
	for a in groups:
		if colorint.has(a):
			color = a
	return color

#Determines which player is ai, 0, 1, or 3 for niether
var ai
var nextai = 1
func switchai():
	match nextai:
		0: nextai = 1
		1: nextai = 2
		2: nextai = 0

#Bool which alternates which planet gets deleted, I'm not a fan of this implementation
var deletelocation = false
func passturn():
	#Advance turn count
	turncount += 1
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
	if turncount == 8:
		endgame()
		return
	#Pass turn to next player or ai
	if playerturn == 1:
		playerturn = 0
	else:
		playerturn = 1
	if playerturn == ai: aimove(0)
	else: allset = true


var transition
func endgame():
	allset = false
	if turncount == 8:
		for a in colorint:
			var planets = get_tree().get_nodes_in_group(a)
			for b in planets:
				response += 1
				b.endgame()
			if planets:
				await get_tree().create_timer(2).timeout
				inqueue.append("updateinv")
				await get_tree().create_timer(1).timeout
		inqueue.append("score")
	else: score()

func score():
	if turncount == 8:
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
	ai = nextai
	get_tree().get_root().get_node("Main").add_child(borderload.instantiate())
	border = get_tree().get_root().get_node("Main").get_node("Border")
	for a in inventories:
		a.reset()
	playerinv = [[1,0,0,0,0,0,0],[0,0,0,0,0,0,0]]
	playerturn = 0
	turncount = 0
	border.rotating = true

var inqueue = []
func awaitdictionary(function):
	match function:
#		"aiturn_2": aiturn(2)
		"aimove_1": aimove(1)
		"updateinv": updateinv()
		"score": score()

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
