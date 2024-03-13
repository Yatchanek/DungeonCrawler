extends TextureProgressBar

func update_value(_value):
	value = _value
	if value <= 0:
		self_modulate = Color(0.2, 0.2, 0.2, 0.5)
	else:
		self_modulate = Color.WHITE

