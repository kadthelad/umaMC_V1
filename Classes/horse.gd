class_name Horse

var i_id: int = -1
var i_name: String = "NONEXISTANT"
var i_gender: int = 1
var i_birth_date: String = ""
var i_death_date: String = ""
var i_notes: String = ""
var i_speed: float = 0.0
var i_jump_height: float = 0.0
var i_heart_amount: float = 0.0
var i_stable_id: int = -1
var i_sire_id: int = -1
var i_dam_id: int = -1

func _init(id: int = -1, h_name: String = "NONEXISTANT", gender: int = 1, birth_date: String = "",
				death_date: String = "", notes: String = "", speed: float = 0.0,
				jump_height: float = 0.0, heart_amount: float = 0.0, stable_id: int = -1,
				sire_id: int = -1, dam_id: int = -1) -> void:
	i_id = id
	i_name = h_name
	i_gender = gender
	i_birth_date = birth_date
	i_death_date = death_date
	i_notes = notes
	i_speed = speed
	i_jump_height = jump_height
	i_heart_amount = heart_amount
	i_stable_id = stable_id
	i_sire_id = sire_id
	i_dam_id = dam_id

static func get_all_horses_data(sqlite_connection : SQLiteConnectionUtils, filter: String = "") -> Array[Horse]:
	var horses_array: Array[Horse] = []
	var data := sqlite_connection.send_query("SELECT * FROM Horse" + filter)
	for horse_data in data:
		horses_array.append(make_horse_from_data(horse_data))
	
	return horses_array

static func get_horse_data(sqlite_connection : SQLiteConnectionUtils, id: int) -> Horse:
	if id == -1:
		return Horse.new()
	
	var horse_data = sqlite_connection.send_query("SELECT * FROM Horse WHERE id="+str(id))
	if horse_data != []:
		horse_data = horse_data[0] # There will be 1 line anyway, no need to bother making another variable
		
		return make_horse_from_data(horse_data)
	return Horse.new()

static func make_horse_from_data(horse_data: Dictionary) -> Horse:
	var horse := Horse.new()
	horse.i_id = horse_data["id"]
	horse.i_name = horse_data["name"]
	horse.i_gender = horse_data["gender"]
	horse.i_birth_date = horse_data["birth_date"]
	horse.i_death_date = horse_data["death_date"]
	horse.i_notes = horse_data["notes"]
	horse.i_speed = horse_data["speed"]
	horse.i_jump_height = horse_data["jump_height"]
	horse.i_heart_amount = horse_data["heart_amount"]
	if horse_data["stable_id"] != null:
		horse.i_stable_id = horse_data["stable_id"]
	if horse_data["sire_id"] != null:
		horse.i_sire_id = horse_data["sire_id"]
	if horse_data["dam_id"] != null:
		horse.i_dam_id = horse_data["dam_id"]
	
	return horse
