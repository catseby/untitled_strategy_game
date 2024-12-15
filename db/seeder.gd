extends Node

var db : SQLite

func _ready() -> void:
	DirAccess.remove_absolute("res://db/sqlite.db")
	
	db = SQLite.new()
	db.path = "res://db/sqlite.db"
	db.open_db()
	
	var residents = {
		"id" : {"data_type": "int", "primary_key": true, "auto_increment": true},
		"first_name" : {"data_type":"text"},
		"last_name" : {"data_type":"text"},
		"vitality" : {"data_type":"int"}
	}
	db.create_table("residents",residents)
