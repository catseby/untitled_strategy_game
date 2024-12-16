extends "res://code/scripts/level.gd"

const SKILLS = [
	preload("res://level/prefab/skills/punch.tscn"),
	preload("res://level/prefab/skills/bandage.tscn"),
	preload("res://level/prefab/skills/rock_throw.tscn"),
	preload("res://level/prefab/skills/area_heal.tscn")
]

var db : SQLite

func _ready() -> void:
	db = SQLite.new()
	db.path = "res://db/sqlite.db"
	db.open_db()
	
	var residents = db.select_rows("residents","",["*"])
	#print(residents)
	db.close_db()
	
	for spawn in spawns.get_children():
		var units : Array[Node] = []
		for i in spawn.unit_count:
			var unit = UNIT.instantiate()
			var data = residents.pop_at(randi_range(0,residents.size()-1))
			
			unit.first_name = data["first_name"]
			unit.last_name = data["last_name"]
			unit.move_range = round((int(data["agility"]) + 1) / 1.25)
			unit.max_hit_points = int(data["vitality"]) + 1
			unit.turn_order += int(data["willpower"])
			
			var skills = JSON.parse_string(data["skills"])
			for j in skills.size():
				var skill = SKILLS[skills[j]].instantiate()
				unit.get_node("Skills").add_child(skill)
			
			units.append(unit)
		spawn.queue_units(units)
	
	for spawn in spawns.get_children():
		spawn.add_units()
	#await get_tree().create_timer(1).timeout
	update_objectives()
	next()
