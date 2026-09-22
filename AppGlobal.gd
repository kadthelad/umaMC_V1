extends Node

signal database_changed

var connection := SQLiteConnectionUtils.new(""):
	set(value):
		if value.connection_success:
			database_changed.emit()
