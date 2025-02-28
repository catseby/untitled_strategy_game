extends Node

var SKILLS = [
	preload("res://level/prefab/skills/punch.tscn"),
	preload("res://level/prefab/skills/bandage.tscn"),
	preload("res://level/prefab/skills/rock_throw.tscn"),
	preload("res://level/prefab/skills/area_heal.tscn")
]


var db : SQLite

var first_names = ["Alice", "Edward", "Mary", "Henry", "Clara", "William", "Helen", "Charles", "Emma", "George", "Anna", "Thomas", "Rose", "Arthur", "Edith", "Alfred", "Florence", "Harry", "Margaret", "Albert"]
var last_names = ["Johnson", "Brown", "Taylor", "Smith", "Jones", "Williams", "Miller", "Davis", "Wilson", "Anderson", "Clark", "Thomas", "Lewis", "Robinson", "Walker", "Wright", "Young", "Harris", "Martin", "King"]

var stat_points = 36
var entries = 30

var skill_count = 2

func _ready() -> void:
	randomize()
	DirAccess.remove_absolute("res://db/sqlite.db")

	db = SQLite.new()
	db.path = "res://db/sqlite.db"
	db.open_db()

	db.drop_table("residents")

	var residents = {
		"id" : {"data_type": "int", "primary_key": true, "auto_increment": true, "not_null": true},
		"first_name" : {"data_type":"text"},
		"last_name" : {"data_type":"text"},
		"vitality" : {"data_type":"int"},
		"strength" : {"data_type":"int"},
		"agility" : {"data_type":"int"},
		"dexterity" : {"data_type":"int"},
		"intelligence" : {"data_type":"int"},
		"perception" : {"data_type":"int"},
		"willpower" : {"data_type":"int"},
		"charisma" : {"data_type":"int"},
		"skills" : {"data_type":"text"}
	}
	db.create_table("residents",residents)

	for i in entries:
		var stats : Array[int] = [1,1,1,1,1,1,1,1]
		for j in stat_points:
			var index = randi_range(0,stats.size()-1)
			if stats[index] >= 10:
				j -= 1
				continue
			else:
				stats[index] += 1

		var skills : Array[int] = []
		for j in skill_count:
			var index = randi_range(0,SKILLS.size()-1)
			if !skills.has(index):
				skills.append(index)
			else:
				j -= 1
				continue

		var resident = {
			"first_name" : first_names.pick_random(),
			"last_name" : last_names.pick_random(),
			"vitality" : stats[0],
			"strength" : stats[1],
			"agility" : stats[2],
			"dexterity" : stats[3],
			"intelligence" : stats[4],
			"perception" : stats[5],
			"willpower" : stats[6],
			"charisma" : stats[7],
			"skills" : JSON.stringify(skills)
		}

		db.insert_row("residents",resident)

	db.close_db()
