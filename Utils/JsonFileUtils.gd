class_name JsonFileUtils
extends RefCounted
# A utility class for reading and writing .json files using Godot's JSON.
# Provides static methods for common operations with error handling.

# Internal storage.
static var _data: Dictionary = {}
static var _loaded: bool = false
static var _filepath: String = ""

# ------------------------------------------------------------------
# Public API
# ------------------------------------------------------------------

## Loads a JSON file from the given path.
## Returns true if the file was loaded and parsed successfully, false otherwise.
static func load_json(filepath: String) -> bool:
	_filepath = filepath
	var file := FileAccess.open(filepath, FileAccess.READ)
	if file == null:
		push_warning("JsonFileUtils: Could not open file '%s' for reading." % filepath)
		_loaded = false
		_data = {}
		return false
	
	var content := file.get_as_text()
	file.close()
	
	var result: Variant = JSON.parse_string(content)
	if result == null:
			_loaded = false
			_data = {}
			return false
	else:
		_data = result if result is Dictionary else {}
		_loaded = true
		return true

## Saves the current data to the previously loaded filepath.
## Returns true on success, false otherwise.
static func save_json() -> bool:
	if not _loaded or _filepath.is_empty():
		push_error("JsonFileUtils: No JSON loaded or filepath empty. Use load_json() first.")
		return false
	return _save_to_file(_filepath)

## Saves the current data to a specific filepath (overwrites the internal path).
static func save_json_as(filepath: String) -> bool:
	_filepath = filepath
	_loaded = true
	return _save_to_file(filepath)

## Returns a deep copy of the internal data (to prevent external modifications).
static func get_data() -> Dictionary:
	return _data.duplicate(true)

## Replaces the internal data with a new dictionary.
static func set_data(new_data: Dictionary) -> void:
	_data = new_data.duplicate(true)
	_loaded = true

## Gets a value using a dot‑notation path (e.g., "player.name").
## Returns 'default' if the path does not exist.
static func get_value(path: String, default_value = null):
	if not _loaded:
		push_error("JsonFileUtils: No JSON loaded. Call load_json() first.")
		return default_value
	var keys := path.split(".")
	var current = _data
	for key in keys:
		if current is Dictionary and current.has(key):
			current = current[key]
		else:
			return default_value
	return current

## Sets a value using a dot‑notation path, creating intermediate dictionaries as needed.
static func set_value(path: String, value) -> void:
	if not _loaded:
		push_error("JsonFileUtils: No JSON loaded. Call load_json() first.")
		return
	var keys := path.split(".")
	var current = _data
	# Navigate to the second-last key, creating dictionaries if necessary.
	for i in range(keys.size() - 1):
		var key = keys[i]
		if not (current is Dictionary and current.has(key)):
			# If the key doesn't exist, create a new dictionary.
			current[key] = {}
		current = current[key]
	# Now set the value at the final key.
	var last_key = keys[-1]
	current[last_key] = value

## Checks if a dot‑notation path exists.
static func has_key(path: String) -> bool:
	if not _loaded:
		return false
	var keys := path.split(".")
	var current = _data
	for key in keys:
		if current is Dictionary and current.has(key):
			current = current[key]
		else:
			return false
	return true

## Erases a key at the given dot‑notation path.
static func erase_key(path: String) -> void:
	if not _loaded:
		return
	var keys := path.split(".")
	if keys.is_empty():
		return
	var current = _data
	# Navigate to the parent of the last key.
	for i in range(keys.size() - 1):
		var key = keys[i]
		if current is Dictionary and current.has(key):
			current = current[key]
		else:
			return  # Path doesn't exist, nothing to erase.
	var last_key = keys[-1]
	if current is Dictionary:
		current.erase(last_key)

## Clears the internal data (sets to empty dictionary).
static func clear() -> void:
	_data = {}
	_loaded = true   # still considered loaded but empty

## Resets the utility state (clears data, marks as unloaded, clears filepath).
static func reset() -> void:
	_data = {}
	_loaded = false
	_filepath = ""

# ------------------------------------------------------------------
# Convenience helpers
# ------------------------------------------------------------------

## Creates a new JSON structure with default data (does not save automatically).
static func set_defaults(defaults: Dictionary) -> void:
	_data = defaults.duplicate(true)
	_loaded = true

## Loads JSON, and if it fails, creates default data and saves it.
## Returns true if loaded successfully (either from file or created).
static func load_or_create_default(filepath: String, defaults: Dictionary) -> bool:
	if load_json(filepath):
		return true
	else:
		set_defaults(defaults)
		return save_json_as(filepath)

# ------------------------------------------------------------------
# Internal helpers
# ------------------------------------------------------------------

static func _save_to_file(filepath: String) -> bool:
	var json_string := JSON.stringify(_data, "\t")  # pretty print with tabs
	var file := FileAccess.open(filepath, FileAccess.WRITE)
	if file == null:
		push_error("JsonFileUtils: Could not open file '%s' for writing." % filepath)
		return false
	file.store_string(json_string)
	file.close()
	return true
