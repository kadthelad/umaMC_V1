class_name ParentContainerUI
extends VBoxContainer

@onready var sire_button: Button = %SireButton
@onready var dam_button: Button = %DamButton

var sire_id := -1
var dam_id := -1

func _ready() -> void:
	sire_button.pressed.connect(_on_horse_button_clicked.bind(sire_id))
	dam_button.pressed.connect(_on_horse_button_clicked.bind(dam_id))

func _on_horse_button_clicked(horse_id: int) -> void:
	print("checking horse with ID = ", horse_id)
