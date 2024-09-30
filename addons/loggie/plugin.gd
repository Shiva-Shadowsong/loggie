@tool
class_name LoggieEditorPlugin extends EditorPlugin

## The global singleton name that will be used to refer to Loggie.
## You may adjust it here if you prefer something "log", "logger", etc..
## If you do that, disable the plugin -> go to Autoloads -> remove the previously added "Loggie" autoload,
## and re-enable the plugin.
const singleton_name : String = "Loggie"

## The dictionary which is used to derive the default values and other values associated to each setting
## relevant to loggie, particularly important for the default way of loading [LoggieSettings] and
## setting up Godot Project Settings related to Loggie.
const project_settings = {
	"custom_settings_path" = {
		"path" : "loggie/custom_settings/custom_settings",
		"default_value" : "",
		"type" : TYPE_STRING,
		"hint" : PROPERTY_HINT_TYPE_STRING,
		"hint_string" : "e.g. res://addons/loggie/custom_loggie_settings.gd",
		"doc" : "The path to a custom .gd script that a valid LoggieSettings (or an extension of it) class can be instantiated from."
	},
	"terminal_mode" = {
		"path": "loggie/general/terminal_mode",
		"default_value" : LoggieTools.TerminalMode.BBCODE,
		"type" : TYPE_INT,
		"hint" : PROPERTY_HINT_ENUM,
		"hint_string" : "Plain:0,ANSI:1,BBCode:2",
		"doc" : "Set the terminal mode.",
	},
	"log_level" = {
		"path": "loggie/general/log_level",
		"default_value" : LoggieTools.LogLevel.INFO,
		"type" : TYPE_INT,
		"hint" : PROPERTY_HINT_ENUM,
		"hint_string" : "Error:0,Warn:1,Notice:2,Info:3,Debug:4",
		"doc" : "",
	},
	"show_system_specs" = {
		"path": "loggie/general/show_system_specs",
		"default_value" : true,
		"type" : TYPE_BOOL,
		"hint" : PROPERTY_HINT_NONE,
		"hint_string" : "",
		"doc" : "",
	},
	"output_timestamps" = {
		"path": "loggie/timestamps/output_timestamps",
		"default_value" : true,
		"type" : TYPE_BOOL,
		"hint" : PROPERTY_HINT_NONE,
		"hint_string" : "",
		"doc" : "",
	},
	"timestamps_use_utc" = {
		"path": "loggie/timestamps/timestamps_use_utc",
		"default_value" : true,
		"type" : TYPE_BOOL,
		"hint" : PROPERTY_HINT_NONE,
		"hint_string" : "",
		"doc" : "",
	},
	"output_errors_to_console" = {
		"path": "loggie/preprocessing/output_errors_also_to_console",
		"default_value" : true,
		"type" : TYPE_BOOL,
		"hint" : PROPERTY_HINT_NONE,
		"hint_string" : "",
		"doc" : "",
	},
	"output_warnings_to_console" = {
		"path": "loggie/preprocessing/output_warnings_also_to_console",
		"default_value" : true,
		"type" : TYPE_BOOL,
		"hint" : PROPERTY_HINT_NONE,
		"hint_string" : "",
		"doc" : "",
	},
	"use_print_debug_for_debug_msgs" = {
		"path": "loggie/preprocessing/use_print_debug_for_debug_msgs",
		"default_value" : false,
		"type" : TYPE_BOOL,
		"hint" : PROPERTY_HINT_NONE,
		"hint_string" : "",
		"doc" : "",
	},
	"derive_and_display_class_names_from_scripts" = {
		"path": "loggie/preprocessing/derive_and_display_class_names_from_scripts",
		"default_value" : true,
		"type" : TYPE_BOOL,
		"hint" : PROPERTY_HINT_NONE,
		"hint_string" : "",
		"doc" : "",
	},
	"output_message_domain" = {
		"path": "loggie/preprocessing/output_message_domain",
		"default_value" : true,
		"type" : TYPE_BOOL,
		"hint" : PROPERTY_HINT_NONE,
		"hint_string" : "",
		"doc" : "",
	},
	"box_characters_mode" = {
		"path": "loggie/preprocessing/box_characters_mode",
		"default_value" : LoggieTools.BoxCharactersMode.COMPATIBLE,
		"type" : TYPE_INT,
		"hint" : PROPERTY_HINT_ENUM,
		"hint_string" : "Compatible:0,Pretty:1",
		"doc" : "",
	}
}

func _enter_tree():
	# Registers a new autload singleton with the given SingletonName as one connected to the main loggie script.
	add_autoload_singleton(singleton_name, "res://addons/loggie/loggie.gd")
	add_loggie_project_settings()

func _exit_tree() -> void:
	remove_loggie_project_setings()
	remove_autoload_singleton(singleton_name)

## Adds new Loggie related ProjectSettings to Godot.
func add_loggie_project_settings():
	for setting in project_settings.values():
		add_project_setting(setting["path"], setting["default_value"], setting["type"], setting["hint"], setting["hint_string"], setting["doc"])

## Removes Loggie related ProjectSettings from Godot.
func remove_loggie_project_setings():
	for setting in project_settings.values():
		ProjectSettings.set_setting(setting["path"], null)
	
	var error: int = ProjectSettings.save()
	if error: 
		push_error("Loggie - Encountered error %d while saving project settings." % error)

## Adds a new project setting to Godot.
func add_project_setting(setting_name: String, default_value : Variant, value_type: int, type_hint: int = PROPERTY_HINT_NONE, hint_string: String = "", documentation : String = ""):
	if ProjectSettings.has_setting(setting_name): 
		return

	ProjectSettings.set_setting(setting_name, default_value)
	
	ProjectSettings.add_property_info({
		"name": setting_name,
		"type": value_type,
		"hint": type_hint,
		"hint_string": hint_string,
		"doc" : documentation
	})

	ProjectSettings.set_initial_value(setting_name, default_value)
	
	var error: int = ProjectSettings.save()
	if error: 
		push_error("Loggie - Encountered error %d while saving project settings." % error)
