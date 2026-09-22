extends Control

@onready var main_container: VBoxContainer = %MainContainer
var current_window: Control = null

@onready var h_manager_button: Button = %HManagerButton
@onready var h_pedigree_button: Button = %HPedigreeButton
@onready var db_path_option_button: OptionButton = %DBPathOptionButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	h_manager_button.pressed.connect(show_window.bind(SceneLoader.HORSE_MANAGER_WINDOW))
	h_pedigree_button.pressed.connect(show_window.bind(SceneLoader.HORSE_PEDIGREE_WINDOW))
	
	# Load db_path_option_button...
	# -> Load config, or create it if not existing
	var json_path := "user://paths.json"
	var loaded := JsonFileUtils.load_json(json_path)
	if loaded:
		print("Settings loaded successfully.")
	else:
		print("Failed to load paths, creating file...")
		JsonFileUtils.save_json_as(json_path)
	var paths_data: Array = JsonFileUtils.get_value("paths", [])
	for path in paths_data:
		db_path_option_button.add_item(path)

## Instantiates window (PackedScene)
func show_window(window: PackedScene) -> void:
	var instantiated_window: Control = window.instantiate()
	
	if current_window != null:
		current_window.queue_free()
	current_window = instantiated_window
	main_container.add_child(instantiated_window)


func _on_add_database_button_pressed() -> void:
	pass # Replace with function body.

## Load the database
func _on_db_path_option_button_item_selected(index: int) -> void:
	AppGlobal.connection = SQLiteConnectionUtils.new(db_path_option_button.text)
