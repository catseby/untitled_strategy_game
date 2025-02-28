extends Control

const HP_BAR = preload("res://level/prefab/hp_bar.tscn")
const NAME_LABEL = preload("res://level/prefab/name_label.tscn")
const AP_BAR = preload("res://level/prefab/ap_bar.tscn")
@onready var vbox = $VBox

var column_size = 7

func update(unit):
	for child in vbox.get_children():
		child.queue_free()

	var name_label = NAME_LABEL.instantiate()
	name_label.text = unit.full_name
	print("group " + str(unit.group))
	if unit.group == "Hunters":
		name_label.modulate = Color("00b4ff")
	else:
		name_label.modulate = Color("ff0000")
	vbox.add_child(name_label)


	var max_hp = unit.max_hit_points
	var hp = unit.hit_points

	set_hp(hp,max_hp)

	var max_ap = unit.max_action_points
	var ap = unit.action_points

	set_ap(ap,max_ap)

func set_hp(hp,max_hp):
	var first_pass = true
	while max_hp > 0:
		var i = 0
		var looping = true
		var hbox = HBoxContainer.new()
		vbox.add_child(hbox)
		while max_hp > 0 and looping:
			i += 1
			max_hp -= 1
			hp -= 1
			var bar = HP_BAR.instantiate()
			if first_pass:
				bar.size_flags_horizontal = bar.SIZE_EXPAND_FILL
			if hp < 0:
				bar.modulate = Color(0.4,0.4,0.4,0.5)
			hbox.add_child(bar)

			if i >= column_size:
				first_pass = false
				looping = false

func set_ap(ap,max_ap):
	var first_pass = true
	while max_ap > 0:
		var i = 0
		var looping = true
		var hbox = HBoxContainer.new()
		vbox.add_child(hbox)
		while max_ap > 0 and looping:
			i += 1
			max_ap -= 1
			ap -= 1
			var bar = AP_BAR.instantiate()
			if first_pass:
				bar.size_flags_horizontal = bar.SIZE_EXPAND_FILL
			if ap < 0:
				bar.modulate = Color(0.4,0.4,0.4,0.5)
			hbox.add_child(bar)

			if i >= column_size:
				first_pass = false
				looping = false
