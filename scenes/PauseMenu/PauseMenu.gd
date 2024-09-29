extends Control

const confirm_menu = "Go back to Main Menu ?"
const confirm_restart = "Restart the Game ?"
const confirm_quit = "Quit the Game ?"

@onready var confirm_dialog = %ConfirmDialog
@onready var accept_dialog = %AcceptDialog
@onready var sub_menu_container = %SubMenuContainer
@onready var resume_button = %ResumeButton
@onready var save_button = %SaveButton

func _process(_delta):
	if visible and Input.is_action_just_pressed("ui_cancel"):
		if sub_menu_container.visible:
			sub_menu_container.visible = false
		
		_on_resume_button_pressed()

func _ready():
	if OS.has_feature("web"):
		%ExitButton.hide()

	set_process(false)

func _on_resume_button_pressed():
	hide()
	set_process(false)
	get_tree().paused = false

func _on_restart_button_pressed():
	confirm_dialog.popup_confirm(confirm_restart, _on_confirm_restart_confirmed)

func _on_options_button_pressed():
	sub_menu_container.show()

func _on_main_menu_button_pressed():
	confirm_dialog.popup_confirm(confirm_menu, _on_confirm_main_menu_confirmed)

func _on_exit_button_pressed():
	confirm_dialog.popup_confirm(confirm_quit, _on_confirm_exit_confirmed)

func _on_confirm_restart_confirmed():
	hide()
	SceneLoader.change_scene(get_tree().current_scene.scene_file_path)

func _on_confirm_main_menu_confirmed():
	hide()
	SceneLoader.change_scene(RGT_Globals.main_menu_setting)

func _on_confirm_exit_confirmed():
	get_tree().quit()

func _on_back_button_pressed():
	sub_menu_container.hide()

func _on_save_button_pressed() -> void:
	save_button.disabled = true
	
	accept_dialog.dialog_text = "Saving..."
	
	var button = accept_dialog.get_ok_button()
	
	button.disabled = true
	
	accept_dialog.popup_centered()
	
	if SaveHelper.save({}) == OK:
		hide()
		
		#Take screenshot and save it
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(
			SaveHelper.save_dir_path + "/" + SaveHelper.last_saved_file_name + ".png"
		)
		
		show()
	
		accept_dialog.dialog_text = "The game is saved !"
	else:
		accept_dialog.dialog_text = "Cannot save the game !"
	
	button.disabled = false

func _on_accept_dialog_confirmed() -> void:
	save_button.disabled = false
