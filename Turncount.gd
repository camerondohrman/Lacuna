extends Node2D

func turncountadvance():
	
	match Global.turncount:
		0: pass
		1: get_node("0").visible = false
		2: get_node("1").visible = false
		3: get_node("2").visible = false
		4: get_node("3").visible = false
		5: get_node("4").visible = false
		6: get_node("5").visible = false
		7: get_node("6").visible = false
		8: get_node("7").visible = false
