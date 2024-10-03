@tool
class_name LoggieEditorPlugin extends EditorPlugin

func _enter_tree():
	add_autoload_singleton(LoggieSettings.loggie_singleton_name, "res://addons/loggie/loggie.gd")
	add_loggie_project_settings()

func _exit_tree() -> void:
	remove_loggie_project_setings()
	remove_autoload_singleton(LoggieSettings.loggie_singleton_name)

## Adds new Loggie related ProjectSettings to Godot.
func add_loggie_project_settings():
	for setting in LoggieSettings.project_settings.values():
		add_project_setting(setting["path"], setting["default_value"], setting["type"], setting["hint"], setting["hint_string"], setting["doc"])

## Removes Loggie related ProjectSettings from Godot.
func remove_loggie_project_setings():
	for setting in LoggieSettings.project_settings.values():
		ProjectSettings.set_setting(setting["path"], null)
	
	var error: int = ProjectSettings.save()
	if error: 
		push_error("Loggie - Encountered error %d while saving project settings." % error)

## Adds a new project setting to Godot.
## TODO: Figure out how to also add the documentation to the ProjectSetting so that it shows up 
## in the Godot Editor tooltip when the setting is hovered over.
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
