@tool
extends EditorPlugin

## The global singleton name that will be used to refer to Loggie.
## You may adjust it here if you prefer something "log", "logger", etc..
const singleton_name : String = "Loggie"

func _enter_tree():
	# Registers a new autload singleton with the given SingletonName as one connected to the main loggie script.
	add_autoload_singleton(singleton_name, "res://addons/loggie/loggie.gd")
	
	# Adds new ProjectSettings to Godot which are related to Loggie.
	add_project_setting("Loggie/TerminalMode", LoggieTools.TerminalMode.BBCODE, LoggieTools.TerminalMode.BBCODE, TYPE_INT, PROPERTY_HINT_ENUM, "Plain:0,ANSI:1,BBCode:2")
	add_project_setting("Loggie/BoxCharactersMode", LoggieTools.BoxCharactersMode.COMPATIBLE, LoggieTools.BoxCharactersMode.COMPATIBLE, TYPE_INT, PROPERTY_HINT_ENUM, "Compatible:0,Pretty:1")
	add_project_setting("Loggie/LogLevel", LoggieTools.LogLevel.INFO, LoggieTools.LogLevel.INFO, TYPE_INT, PROPERTY_HINT_ENUM, "Error:0,Warn:1,Notice:2,Info:3,Debug:4")
	add_project_setting("Loggie/ShowSystemSpecs", true, true, TYPE_BOOL)
	add_project_setting("Loggie/OutputMessageDomain", false, false, TYPE_BOOL)
	add_project_setting("Loggie/OutputErrorsAlsoToConsole", true, true, TYPE_BOOL)
	add_project_setting("Loggie/OutputWarningsAlsoToConsole", true, true, TYPE_BOOL)
	add_project_setting("Loggie/UsePrintDebugForDebugMessages", false, false, TYPE_BOOL)
	add_project_setting("Loggie/DeriveAndDisplayClassNamesFromScripts", true, true, TYPE_BOOL)
	add_project_setting("Loggie/OutputTimestamps", true, true, TYPE_BOOL)
	add_project_setting("Loggie/TimestampsUseUTC", true, true, TYPE_BOOL)

func add_project_setting(p_name: String, p_default, p_actual, p_type: int, p_hint: int = PROPERTY_HINT_NONE, p_hint_string: String = ""):
	if ProjectSettings.has_setting(p_name): 
		return

	ProjectSettings.set_setting(p_name, p_actual)
	
	ProjectSettings.add_property_info({
		"name": p_name,
		"type": p_type,
		"hint": p_hint,
		"hint_string": p_hint_string,
	})
	
	ProjectSettings.set_initial_value(p_name, p_default)
	
	var error: int = ProjectSettings.save()
	
	if error: 
		push_error("Loggie - Encountered error %d while saving project settings." % error)
