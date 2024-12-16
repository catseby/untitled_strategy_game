extends "res://code/scripts/skills/skill.gd"

@export var damage : int = 1

func apply_effect(unit):
	unit.hit(Attack.new(damage))
