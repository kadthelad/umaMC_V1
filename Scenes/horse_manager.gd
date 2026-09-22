extends Control

@onready var horse_list: ItemList = %HorseList
@onready var save_button: Button = %SaveButton

# HORSE INFORMATION #
@onready var horse_name_label: LineEdit = %HorseNameLabel
@onready var gender_check_button: CheckButton = %GenderCheckButton
@onready var birth_date_line_edit: LineEdit = %BirthDateLineEdit
@onready var death_date_line_edit: LineEdit = %DeathDateLineEdit
@onready var notes_text_edit: TextEdit = %NotesTextEdit
@onready var speed_line_edit: LineEdit = %SpeedLineEdit
@onready var jump_height_line_edit: LineEdit = %JumpHeightLineEdit
@onready var heart_amount_line_edit: LineEdit = %HeartAmountLineEdit
@onready var sire_id_line_edit: LineEdit = %SireIDLineEdit
@onready var dam_id_line_edit: LineEdit = %DamIDLineEdit
@onready var editable_controls := [
	horse_name_label, gender_check_button, birth_date_line_edit, death_date_line_edit,
	notes_text_edit, speed_line_edit, jump_height_line_edit, heart_amount_line_edit,
	sire_id_line_edit, dam_id_line_edit,
]
# =============== #

@onready var caracteristic_option_button: OptionButton = %CaracteristicOptionButton
@onready var horse_name_line_edit: LineEdit = %HorseNameLineEdit
@onready var sort_check_button: CheckButton = %SortCheckButton

var database_path := ""
var sqlite_instance := SQLiteConnectionUtils.new(database_path)

var is_editing: bool = false:
	set(value):
		is_editing = value
		change_view_mode(value)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_UI()
	refresh_UI()

func load_UI() -> void:
	var horse_caracteristics := sqlite_instance.send_query("PRAGMA table_info(Horse);")
	if horse_caracteristics != []:
		for caracteristic : Dictionary in horse_caracteristics:
			caracteristic_option_button.add_item(caracteristic["name"])

func refresh_UI() -> void:
	horse_list.clear()
	var filter := ""
	if horse_name_line_edit.text != "":
		filter += " WHERE name LIKE " + '"'+ horse_name_line_edit.text + '%"'
	if caracteristic_option_button.get_selected_id() != -1:
		filter += " ORDER BY " + caracteristic_option_button.get_item_text(caracteristic_option_button.get_selected_id())
		if sort_check_button.button_pressed:
			filter += " DESC"
	
	var horses_array: Array[Horse] = Horse.get_all_horses_data(sqlite_instance, filter)
	for i in range(horses_array.size()):
		var horse := horses_array[i]
		horse_list.add_item("%s | %s" % [horse.i_id, horse.i_name])
		horse_list.set_item_metadata(i, horse.i_id)

func _on_horse_list_item_selected(index: int) -> void:
	is_editing = false # Stop editing
	var selected_horse: Horse = Horse.get_horse_data(sqlite_instance, horse_list.get_item_metadata(index))
	
	# Load selected horse's data
	horse_name_label.text = selected_horse.i_name
	%IdLineEdit.text = str(selected_horse.i_id)
	gender_check_button.button_pressed = bool(selected_horse.i_gender)
	birth_date_line_edit.text = selected_horse.i_birth_date
	death_date_line_edit.text = selected_horse.i_death_date
	notes_text_edit.text = selected_horse.i_notes
	speed_line_edit.text = str(selected_horse.i_speed)
	jump_height_line_edit.text = str(selected_horse.i_jump_height)
	heart_amount_line_edit.text = str(selected_horse.i_heart_amount)
	sire_id_line_edit.text = str(selected_horse.i_sire_id)
	dam_id_line_edit.text = str(selected_horse.i_dam_id)
	
	%EditHorseButton.disabled = false
	%RemoveHorseButton.disabled = false

func change_view_mode(enabling:=false) -> void:
	for ctr: Control in editable_controls:
		if ctr is LineEdit or ctr is TextEdit:
			ctr.editable = enabling
		else:
			ctr.disabled = !enabling
	save_button.disabled = !enabling


func _on_register_horse_button_pressed() -> void:
	if database_path == "":
		return
	is_editing = true
	# Clear all written data
	for ctr: Control in editable_controls:
		if ctr is LineEdit or ctr is TextEdit:
			ctr.text = ""
	
	# Find first unused id
	var unused_id: int = sqlite_instance.send_query("SELECT seq FROM sqlite_sequence WHERE name='Horse'")[0]["seq"]
	#var unused_id := 1
	#var horses_array := Horse.get_all_horses_data(sqlite_instance)
	#while horses_array[unused_id-1].i_id == unused_id:
		#if unused_id < horses_array.size():
			#unused_id += 1
		#else:
			#unused_id += 1
			#break
	
	%IdLineEdit.text = str(unused_id+1)
	%EditHorseButton.disabled = true
	%RemoveHorseButton.disabled = true

func _on_edit_horse_button_pressed() -> void:
	is_editing = true

func _on_remove_horse_button_pressed() -> void:
	# Delete selected horse
	if !(sqlite_instance.delete_row("Horse", "id = " + str(%IdLineEdit.text))):
		var popup_window: PopupMessage = SceneLoader.POPUP_WINDOW.instantiate()
		add_child(popup_window)
		popup_window.popup_window("Error!",
		"There is a problem with the request, more information here: " + sqlite_instance.connection.error_message)
	refresh_UI()


func _on_apply_filter_button_pressed() -> void:
	refresh_UI()


func _on_horse_name_line_edit_text_changed(new_text: String) -> void:
	refresh_UI()


func _on_save_button_pressed() -> void:
	var horse_data: Dictionary = {
		"id" : int(%IdLineEdit.text),
		"name" : horse_name_label.text,
		"gender" : int(gender_check_button.button_pressed),
		"birth_date" : birth_date_line_edit.text,
		"death_date" : death_date_line_edit.text,
		"notes" : notes_text_edit.text,
		"speed" : float(speed_line_edit.text),
		"jump_height" : float(jump_height_line_edit.text),
		"heart_amount" : float(heart_amount_line_edit.text),
		"sire_id" : sire_id_line_edit.text,
		"dam_id" : dam_id_line_edit.text,
	}
	# Check if id already used, if so, modify the horse
	var horses_array := Horse.get_all_horses_data(sqlite_instance)
	for horse : Horse in horses_array:
		if %IdLineEdit.text == str(horse.i_id): # If id exists
			if !(sqlite_instance.update_row("Horse", "id = " + str(horse.i_id), horse_data)):
				var popup_window: PopupMessage = SceneLoader.POPUP_WINDOW.instantiate()
				add_child(popup_window)
				popup_window.popup_window("Error!",
				"There is a problem with the request, more information here: " + sqlite_instance.connection.error_message)
			refresh_UI()
			return
	# If not, create that horse
	if !(sqlite_instance.insert_row("horse", horse_data)):
		var popup_window: PopupMessage = SceneLoader.POPUP_WINDOW.instantiate()
		add_child(popup_window)
		popup_window.popup_window("Error!",
		"There is a problem with the request, more information here: " + sqlite_instance.connection.error_message)
	
	_on_register_horse_button_pressed()
	refresh_UI()


func _on_apply_database_button_pressed(new_database_path: String) -> void:
	database_path = new_database_path
	sqlite_instance = SQLiteConnectionUtils.new(database_path)
	
	load_UI()
	refresh_UI()
