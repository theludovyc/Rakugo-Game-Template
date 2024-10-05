extends ScrollContainer

var SavePanel = preload("res://scenes/LoadSaveMenu/savePanelContainer.tscn")

@onready var vbox_container = $VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var save_files = SaveHelper.get_save_file_names()
	
	if save_files.is_empty():
		push_warning("No save to load")
		pass
		
	for save_file in save_files:
		var save_panel = SavePanel.instantiate()
		
		vbox_container.add_child(save_panel)
		
		save_panel.init(save_file)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
