extends HitIndicator

const COLOR_RANGE : Dictionary[int, Color] = {
	-2 : Color(0.0, 1.0, 0.0),
	-1 : Color(0.5, 1.0, 0.5),
	0 : Color(0.8, 0.8, 0.8),
	1 : Color(1.0, 0.2, 0.2),
	2 : Color(0.9, 0.0, 0.0)
}

func setup(origin, damage_dealt, max_health) -> void:
	_setup(origin)
	
	var severity : int = 0
	if damage_dealt != 0 : severity = clampi(roundi(max_health/damage_dealt),-2,2)
	
	offset_amount = offset_amount * abs(severity)
	offset_speed = offset_speed / (abs(severity) + 1)
	
	p_label.text = str(damage_dealt)
	s_label.text = str(damage_dealt)
	
	p_label.modulate = Color(COLOR_RANGE[severity], PRIMARY_ALPHA)
	s_label.modulate = Color(COLOR_RANGE[severity], SECONDARY_ALPHA)
