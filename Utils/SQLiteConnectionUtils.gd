class_name SQLiteConnectionUtils

const DATABASE_PATH := "res://Data/horsemc_db.sqlite"
var connection := SQLite.new()
var connection_success := false

func _init(db_path: String = DATABASE_PATH) -> void:
	connection.verbosity_level = 0
	if !connect_database(db_path):
		printerr("Couldn't connect to database: ", db_path)
	else:
		connection_success = true

func connect_database(db_path: String = DATABASE_PATH) -> bool:
	connection.path = db_path
	
	if connection.error_message == "not an error":
		return true
	return false

func send_query(query: String) -> Array[Dictionary]:
	connection.open_db()
	connection.query(query)
	connection.close_db()
	
	return connection.query_result

func update_row(table_name: String, conditions: String, table_row: Dictionary) -> bool:
	connection.open_db()
	connection.update_rows(table_name, conditions, table_row)
	connection.close_db()
	if connection.error_message == "not an error":
		return true
	return false

func insert_row(table_name: String, row_data: Dictionary) -> bool:
	connection.open_db()
	connection.insert_row(table_name, row_data)
	connection.close_db()
	if connection.error_message == "not an error":
		return true
	return false

func delete_row(table_name: String, conditions: String) -> bool:
	connection.open_db()
	connection.delete_rows(table_name, conditions)
	connection.close_db()
	if connection.error_message == "not an error":
		return true
	return false
