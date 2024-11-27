extends Node

@onready var parent_unit = get_parent().get_parent()
@export var AOE : Array[Vector3i] = [Vector3i.ZERO]
@export var range : int = 5
@export var include_self : bool = false
@export var require_target : bool = true
@export var required_ap : int = 1
@export var end_turn : bool = false
@export var color = COLORS.RED


enum COLORS {
	WHITE = 1,
	BLUE = 2,
	GREEN = 3,
	ORANGE = 4,
	RED = 5
}

var skill : Node = null

func apply_effect(unit):
	unit.hit(Attack.new())

class Attack :
	var damage : int
	var knockback : int
	var knockback_direction : Vector3
	
	func _init(dmg : int = -1,knbk : int = 0,knbk_dir : Vector3 = Vector3.ZERO) -> void:
		damage = dmg
		knockback = knockback
		knockback_direction = knbk_dir
