extends Area2D

var connection = []
var validcheck = false
func _physics_process(_delta):
	if not validcheck:
		validcheck = true
		for a in get_overlapping_areas():
			if not a.get_groups().has("ai"):
				remove_from_group("valid")
		Global.response -= 1
