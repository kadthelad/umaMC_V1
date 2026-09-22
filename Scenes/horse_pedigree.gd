extends Control

@onready var horse_id_line_edit: LineEdit = %HorseIDLineEdit
@onready var inbreeding_container: HBoxContainer = %InbreedingContainer
@onready var load_pedigree_option_button: OptionButton = %LoadPedigreeOptionButton
@onready var pedigree_container: HBoxContainer = %PedigreeContainer
@onready var current_horse_label: Label = %CurrentHorseLabel

var database_path := ""
var sqlite_instance := SQLiteConnectionUtils.new(database_path)

const PEDIGREE_OPTIONS: Dictionary[String, int] = {
	"Load Pedigree (3 gen.)" : 3,
	"Load Pedigree (5 gen.)" : 5,
	"(good luck) Load Pedigree (8 gen.)" : 8,
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Fill OptionButton
	for option: String in PEDIGREE_OPTIONS:
		load_pedigree_option_button.add_item(option, PEDIGREE_OPTIONS[option])
	load_pedigree_option_button.select(0)


## Load the horse's pedigree
func load_pedigree(horse_id: int, number_generations: int) -> void:
	# Destroy current pedigree
	for child in pedigree_container.get_children():
		if child is VBoxContainer:
			child.queue_free()
	
	# See if the horse exists
	var child_horse := Horse.get_horse_data(sqlite_instance, horse_id)
	if child_horse.i_id == -1:
		return
	
	current_horse_label.text = child_horse.i_name
	
	# Build the pedigree
	var current_horse: Horse = Horse.new()
	for i in range(1, number_generations+1):
		var v_box_container := VBoxContainer.new()
		if i == 1: # Start the pedigree
			# Do for the child..
			build_parents(child_horse, v_box_container)
		else: # Continue the pedigree
			# If this horse has a parent, build its parent_container
			if pedigree_container.get_child(i-1) is VBoxContainer:
				for child: ParentContainerUI in pedigree_container.get_child(i-1).get_children():
					# Do for the sire..
					current_horse = Horse.get_horse_data(sqlite_instance, child.sire_id)
					build_parents(current_horse, v_box_container)
					# Then for the dam...
					current_horse = Horse.get_horse_data(sqlite_instance, child.dam_id)
					build_parents(current_horse, v_box_container)
		if v_box_container.get_child_count() > 0:
			pedigree_container.add_child(v_box_container)

func build_parents(horse: Horse, v_box_container: Container) -> void:
	#print("building parents for ", horse.i_id)
	var parent_container: ParentContainerUI = SceneLoader.PARENT_CONTAINER_UI.instantiate()
	v_box_container.add_child(parent_container)
	await parent_container.ready # Without this, I can't access the buttons for the parent node.
	
	parent_container.sire_id = horse.i_sire_id
	if horse.i_sire_id == -1:
		parent_container.sire_button.text = "[NONEXISTANT]"
	else:
		parent_container.sire_button.text = "[%s] %s" % [str(horse.i_sire_id), Horse.get_horse_data(sqlite_instance, horse.i_sire_id).i_name]
	
	parent_container.dam_id = horse.i_dam_id
	if horse.i_dam_id == -1:
		parent_container.dam_button.text = "[NONEXISTANT]"
	else:
		parent_container.dam_button.text = "[%s] %s" % [str(horse.i_dam_id), Horse.get_horse_data(sqlite_instance, horse.i_dam_id).i_name]

func _on_load_pedigree_option_button_item_selected(index: int) -> void:
	if horse_id_line_edit.text.is_valid_int():
		load_pedigree(horse_id_line_edit.text.to_int(), load_pedigree_option_button.get_selected_id())
	else:
		horse_id_line_edit.text = str(-1)

func _on_reload_pedigree_button_pressed() -> void:
	_on_load_pedigree_option_button_item_selected(-1)


func _on_apply_database_button_pressed(new_database_path: String) -> void:
	database_path = new_database_path
	sqlite_instance = SQLiteConnectionUtils.new(database_path)
