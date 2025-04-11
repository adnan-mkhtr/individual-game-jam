extends Label

func _process(_delta):
	if Global.is_level2 == true:
		self.text = "Lives : " + str(Global.lives)
