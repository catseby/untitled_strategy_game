extends Sprite3D

func set_action_points(ap):
	$Unit_Hover_UI/Unit_Hover_UI/AP.text = str(ap)

func set_health_points(hp):
	$Unit_Hover_UI/Unit_Hover_UI/HP.text = str(hp)
