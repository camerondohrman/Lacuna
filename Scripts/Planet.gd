extends Area2D

var selectable = false
var color
var placementload = preload("res://Placement.tscn")
var aiload = preload("res://Potential.tscn")
var connected = []

func _ready():
	color = Global.getcolor(self)

var hovering = false
var previous
func _process(_delta):
	if Global.placing:
		return
	if Global.connected.size() > 0:
		if not Global.connected.has(self):
			return
	if not hovering == previous:
		previous = hovering
		hoveringqueue(hovering)

var legalplacement
var updateconnections = false
var aipotential = false
var drawconnections = false
func _physics_process(_delta):
	if Input.is_action_just_pressed("click"):
		if not Global.allset:
			return
		if not selectable:
			return
		get_node("sound").play()
		if not Global.select:
			updateconnections = true
			drawconnections = true
			selectcircle(true)
			Global.select = self
		elif Global.connected.has(self):
			selectable = false
			Global.deletegroup("potential")
			Global.select.selectcircle(false)
			legalplacement = Line2D.new()
			legalplacement.default_color = Color.MISTY_ROSE
			legalplacement.width = 10
			legalplacement.antialiased = true
			legalplacement.points = PackedVector2Array([0,Global.select.position-position])
			legalplacement.add_to_group("legalplacement")
			legalplacement.end_cap_mode = 2
			legalplacement.z_index = 1
			add_child(legalplacement)
			legalplacement = RayCast2D.new()
			legalplacement.name = "legalplacement"
			legalplacement.target_position = Global.select.position-position
			legalplacement.collide_with_areas = true
			legalplacement.add_to_group("legalplacement")
			add_child(legalplacement)
			legalplacement = get_node("legalplacement")
			Global.select2 = self
			Global.placing = true
			get_tree().get_root().get_node("Main").get_node("Border").add_child(placementload.instantiate())
	if updateconnections:
		updateconnections = false
		var planets = get_tree().get_nodes_in_group(color)
		planets.erase(self)
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsRayQueryParameters2D.create(global_position, Vector2.ZERO, 1, [self])
		query.collide_with_areas = true
		Global.connected.clear()
		connected.clear()
		for a in planets:
			query.to = a.global_position
			var result = space_state.intersect_ray(query)
			if result:
				if result.collider.is_in_group(color):
					if result.collider.position.distance_to(position) > 100:
						connected.append(result.collider)
		if connected.size() == 0:
			Global.allset = false
			await get_tree().create_timer(.2).timeout
			selectcircle(false)
			Global.deselect()
			Global.allset = true
		Global.connected = connected
		if drawconnections:
			drawconnections = false
			for b in connected:
				var line = Line2D.new()
				line.default_color = Color.MISTY_ROSE
				line.end_cap_mode = 2
				line.width = 5
				line.antialiased = true
				line.z_index = 1
				line.points = PackedVector2Array([0,b.position-position])
				line.add_to_group("potential")
				add_child(line)
		if aipotential:
			aipotential = false
			for b in connected:
				var locations = []
				locations.resize(3)
				locations[0] = Vector2((position.x+b.position.x)/2,(position.y+b.position.y)/2)
				locations[1] = Vector2((locations[0].x+b.position.x)/2,(locations[0].y+b.position.y)/2)
				locations[2] = Vector2((position.x+locations[0].x)/2,(position.y+locations[0].y)/2)
				for a in locations:
					Global.response += 1
					var ai_instance = aiload.instantiate()
					ai_instance.position = a
					ai_instance.connection.append(self)
					ai_instance.connection.append(b)
					get_parent().add_child(ai_instance)
			Global.response -= 1

var default_mod
func _on_mouse_entered():
	hovering = true
	get_node("hover").play()

func _on_mouse_exited():
	hovering = false
	get_node("hover").stop()
	
func selectcircle(mode):
	var tween = get_tree().create_tween()
	if mode:
		tween.tween_property(get_node("Select"), "scale", Vector2(1,1), .1)
	else:
		tween.tween_property(get_node("Select"), "scale", Vector2.ZERO, .1)
	
func hoveringqueue(mode):
	if mode:
		selectable = true
		get_node("Sprite2D").play("Hover")
	else:
		selectable = false
		if get_node("Sprite2D"): get_node("Sprite2D").stop()
		
func endgame():
	var sound = get_node("hover")
	sound.volume_db = -10
	sound.play()
	var pawns = get_tree().get_nodes_in_group("pawn")
	var closest
	var closestdistance = INF
	for a in pawns:
		var distance = position.distance_to(a.position)
		if distance < closestdistance:
			closest = a
			closestdistance = distance
	var groups = closest.get_groups()
	var group
	for a in groups:
		if ["0","1"].has(a):
			group = a
	var pawnlabel
	if group == "0":
		pawnlabel = 0
	elif group == "1":
		pawnlabel = 1
	Global.changescore(pawnlabel, Global.colorint.find(color), 1)
	z_index = 2
	var tween = get_tree().get_root().create_tween()
	Global.response -= 1
	tween.tween_property(self,"position",closest.position,3).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(self.queue_free)
#	queue_free()
