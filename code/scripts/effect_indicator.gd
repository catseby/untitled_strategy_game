extends HitIndicator

enum {
	STUN,
	BURN,
	FREEZE,
	BUFF,
	DEBUFF
}

const COLOR_RANGE : Dictionary[int, Color] = {
	STUN : Color(1.0, 1.0, 0.5),
	BURN : Color(1.0, 0.3, 0.0),
	FREEZE : Color(0.0, 0.7, 1.0),
	BUFF : Color(0.6, 1.0, 0.6),
	DEBUFF : Color(0.7, 0.0, 1.0)
}

func setup(origin, effect) -> void:
	_setup(origin)
	
	var severity : int = clampi(effect.severity,0,2)
	
	offset_amount = offset_amount * abs(severity)
	offset_speed = offset_speed / (abs(severity) + 1)
	
	p_label.text = str(effect.name)
	s_label.text = str(effect.name)
	
	p_label.modulate = Color(COLOR_RANGE[effect.type], PRIMARY_ALPHA)
	s_label.modulate = Color(COLOR_RANGE[effect.type], SECONDARY_ALPHA)
