@tool
class_name LoggieEditorPlugin extends EditorPlugin

## The dictionary which is used to derive the default values and other values associated to each setting
## relevant to loggie, particularly important for the default way of loading [LoggieSettings] and
## setting up Godot Project Settings related to Loggie.
const project_settings = {
	"terminal_mode" = {
		"path": "loggie/general/terminal_mode",
		"default_value" : LoggieTools.TerminalMode.BBCODE,
		"type" : TYPE_INT,
		"hint" : PROPERTY_HINT_ENUM,
		"hint_string" : "Plain:0,ANSI:1,BBCode:2",
		"doc" : "Choose the terminal for which loggie should preprocess the output so that it displays as intended.[br][br]Use BBCode for Godot console.[br]Use ANSI for Powershell, Bash, etc.[br]Use PLAIN for log files.",
	},
	"log_level" = {
		"path": "loggie/general/log_level",
		"default_value" : LoggieTools.LogLevel.INFO,
		"type" : TYPE_INT,
		"hint" : PROPERTY_HINT_ENUM,
		"hint_string" : "Error:0,Warn:1,Notice:2,Info:3,Debug:4",
		"doc" : "Choose the level of messages which should be displayed. Loggie displays all messages that are outputted at the currently set level (or any lower level).",
	},
	"show_system_specs" = {
		"path": "loggie/general/show_system_specs",
		"default_value" : true,
		"type" : TYPE_BOOL,
		"hint" : PROPERTY_HINT_NONE,
		"hint_string" : "",
		"doc" : "Should Loggie log the system and device specs of the user as soon as it is booted?",
	},
	"output_timestamps" = {
		"path": "loggie/timestamps/output_timestamps",
		"default_value" : true,
		"type" : TYPE_BOOL,
		"hint" : PROPERTY_HINT_NONE,
		"hint_string" : "",
		"doc" : "Should Loggie output a timestamp prefix with each message, showing the exact moment when that log line was produced?",
	},
	"timestamps_use_utc" = {
		"path": "loggie/timestamps/timestamps_use_utc",
		"default_value" : true,
		"type" : TYPE_BOOL,
		"hint" : PROPERTY_HINT_NONE,
		"hint_string" : "",
		"doc" : "If 'Output Timestamps' is true, should those timestamps use the UTC time. If not, local system time is used instead.",
	},
	"output_errors_to_console" = {
		"path": "loggie/preprocessing/output_errors_also_to_console",
		"default_value" : true,
		"type" : TYPE_BOOL,
		"hint" : PROPERTY_HINT_NONE,
		"hint_string" : "",
		"doc" : "If true, errors printed by Loggie will also be visible through an additional print in the main output.",
	},
	"output_warnings_to_console" = {
		"path": "loggie/preprocessing/output_warnings_also_to_console",
		"default_value" : true,
		"type" : TYPE_BOOL,
		"hint" : PROPERTY_HINT_NONE,
		"hint_string" : "",
		"doc" : "If true, warnings printed by Loggie will also be visible through an additional print in the main output.",
	},
	"use_print_debug_for_debug_msgs" = {
		"path": "loggie/preprocessing/use_print_debug_for_debug_msgs",
		"default_value" : false,
		"type" : TYPE_BOOL,
		"hint" : PROPERTY_HINT_NONE,
		"hint_string" : "",
		"doc" : "If true, 'debug' level messages outputted by Loggie will be printed using Godot's 'print_debug' function, which is more verbose.",
	},
	"derive_and_display_class_names_from_scripts" = {
		"path": "loggie/preprocessing/derive_and_display_class_names_from_scripts",
		"default_value" : true,
		"type" : TYPE_BOOL,
		"hint" : PROPERTY_HINT_NONE,
		"hint_string" : "",
		"doc" : "If true, Loggie will attempt to find out the name of the main class from which the log line is coming and append it in front of the message.",
	},
	"output_message_domain" = {
		"path": "loggie/preprocessing/output_message_domain",
		"default_value" : true,
		"type" : TYPE_BOOL,
		"hint" : PROPERTY_HINT_NONE,
		"hint_string" : "",
		"doc" : "If true, logged messages will have the domain they are coming from prepended to them.",
	},
	"box_characters_mode" = {
		"path": "loggie/preprocessing/box_characters_mode",
		"default_value" : LoggieTools.BoxCharactersMode.COMPATIBLE,
		"type" : TYPE_INT,
		"hint" : PROPERTY_HINT_ENUM,
		"hint_string" : "Compatible:0,Pretty:1",
		"doc" : "There are two sets of box characters defined in LoggieSettings - one set contains prettier characters that produce a nicer looking box, but may not render correctly in the context of various terminals. The other set contains characters that produce a less pretty box, but are compatible with being shown in most terminals.",
	}
}

func _enter_tree():
	add_autoload_singleton("Loggie", "res://addons/loggie/loggie.gd")
	add_loggie_project_settings()

func _exit_tree() -> void:
	remove_loggie_project_setings()
	remove_autoload_singleton("Loggie")

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
## TODO: Figure out how to also add the documentation to the ProjectSetting so that it shows up in the Godot Editor tooltip
## when the setting is hovered over.
func add_project_setting(setting_name: String, default_value : Variant, value_type: int, type_hint: int = PROPERTY_HINT_NONE, hint_string: String = "", documentation : String = ""):
	if ProjectSettings.has_setting(setting_name): 
		return

	ProjectSettings.set_setting(setting_name, default_value)
	
	ProjectSettings.add_property_info({
		"name": setting_name,
		"type": value_type,
		"hint": type_hint,
		"hint_string": hint_string
	})

	ProjectSettings.set_initial_value(setting_name, default_value)
	
	var error: int = ProjectSettings.save()
	if error: 
		push_error("Loggie - Encountered error %d while saving project settings." % error)
