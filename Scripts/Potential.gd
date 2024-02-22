extends Area2D

var connection

func _physics_process(_delta):
	for a in get_overlapping_areas():
		if not a.get_groups().has("ai"):
			remove_from_group("valid")
