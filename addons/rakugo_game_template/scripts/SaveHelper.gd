extends Object
class_name SaveHelper
## Helps to save data in [JSON] format
##
## Here is a sample on how to save data:
## [codeblock]
## var data_to_save := {something:"Something"}
## if SaveHelper.save(data_to_save) != OK:
##   push_error("Cannot save data")
## [/codeblock]
## And how to load and use them:
## [codeblock]
## if SaveHelper.load_last_save() != OK:
##   push_error("Cannot load data")
## var something := SaveHelper.last_saved_data["something"]
## [/codeblock]


## where the data will be saved
const save_dir_path = "user://saves"

## to avoid errors
const json_extension = "json"

## the last saved file name without extension .json
static var last_saved_file_name := ""

## last loaded data [br]
## empty [Dictionary] by default
static var last_loaded_data:Dictionary = {}

## save data in a file [br]
## the file will be created in save_dir_path [br]
## the file_name will be generated from the systemTime in local time [br]
## the file_name name will look like YYYY-MM-DDTHH:MM:SS.json [br]
## yes, the user can modify his system time, so you can use this feature and/or create easter-eggs [br]
## if cannot create saves directory return ERR_CANT_CREATE [br]
## if cannot create and write in the save file return ERR_FILE_CANT_WRITE [br]
## return OK in other cases
static func save(data:Dictionary) -> Error:
	if not DirAccess.dir_exists_absolute(save_dir_path):
		if DirAccess.make_dir_absolute(save_dir_path) != OK:
			push_error("Cannot create saves directory in user://")
			return ERR_CANT_CREATE
	
	var file_name := Time.get_datetime_string_from_system()
	
	var file := FileAccess.open(save_dir_path + "/" + file_name + "." + json_extension, FileAccess.WRITE)
	if file == null:
		push_error("Cannot create the save file in " + save_dir_path)
		return ERR_FILE_CANT_WRITE
	
	var json_data = JSON.stringify(data)
	
	file.store_string(json_data)
	
	last_saved_file_name = file_name
	
	return OK
	
## load data from file [br]
## file_name should looks like YYYY-MM-DDTHH:MM:SS.json [br]
## if the extension .json is missing it will be added [br]
## if the file cannot be opened and read return ERR_FILE_CANT_READ [br]
## if the file cannot be parsed to [JSON] return ERR_INVALID_DATA [br]
## return OK in other cases and save the parsed result in last_loaded_data
static func load(file_name:String) -> Error:
	if not file_name.get_extension() == json_extension:
		file_name += "." + json_extension
	
	var path_to_file := save_dir_path + "/" + file_name
	
	prints("SaveHelper", path_to_file)
	
	var file := FileAccess.open(path_to_file, FileAccess.READ)
	if file == null:
		push_error("Cannot open the save file: " + path_to_file)
		return ERR_FILE_CANT_READ
	
	var json_data := file.get_as_text(true)
	
	var parsed_json = JSON.parse_string(json_data)
	
	if parsed_json == null:
		last_loaded_data = {}
		
		push_error("Cannot parse to json the save file")
		return ERR_INVALID_DATA
	
	last_loaded_data = parsed_json
	
	return OK

static func get_save_file_names() -> PackedStringArray:
	var dirAccess := DirAccess.open(save_dir_path)
	if dirAccess == null:
		push_error("Cannot open the save directory")
		return []
	
	var save_file_names:PackedStringArray = []
	
	dirAccess.list_dir_begin()
	
	var file_name = dirAccess.get_next()

	while not file_name.is_empty():
		if not dirAccess.current_is_dir() \
		and file_name.get_extension() == json_extension:
			save_file_names.push_back(file_name.left(file_name.rfind(".")))
			
		file_name = dirAccess.get_next()
	
	if not save_file_names.is_empty():
		save_file_names.sort()
	
	return save_file_names

## Found last saved file and call load(...) with it [br]
## if cannot open saves directory return ERR_CANT_OPEN [br]
## if the saves directory is empty return ERR_DOES_NOT_EXIST [br]
## in other case return load(...)
static func load_last_save() -> Error:
	var list_file = get_save_file_names()
	
	if list_file.is_empty():
		push_warning("No save to load")
		return ERR_DOES_NOT_EXIST
	
	return SaveHelper.load(list_file[-1])
	
