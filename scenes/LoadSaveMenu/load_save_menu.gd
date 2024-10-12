extends ScrollContainer

const confirm_load = "Are you sure you want to load this save?\n"

var SavePanel = preload("res://scenes/LoadSaveMenu/savePanelContainer.tscn")

@onready var vbox_container = $VBoxContainer

@onready var confirm_dialog = %ConfirmationDialog

enum Modes{
	Loading,
	Deleting
}

var popup_mode = Modes.Loading
var current_save_file_name:String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var save_file_names = SaveHelper.get_save_file_names()
	
	if save_file_names.is_empty():
		push_warning("No save to load")
		pass
		
	for save_file_name in save_file_names:
		var save_panel = SavePanel.instantiate()
		
		vbox_container.add_child(save_panel)
		
		save_panel.init(save_file_name)
		
		save_panel.load_button.pressed.connect(_on_load_button_pressed.bind(save_file_name))

func _on_load_button_pressed(save_file_name:String):
	popup_mode = Modes.Loading
	
	current_save_file_name = save_file_name
	
	confirm_dialog.dialog_text = confirm_load + save_file_name
	
	confirm_dialog.popup_centered()

func _on_confirmation_dialog_confirmed() -> void:
	SaveHelper.save_file_name_to_load = current_save_file_name
	
	SceneLoader.change_scene(RGT_Globals.first_game_scene_setting)
