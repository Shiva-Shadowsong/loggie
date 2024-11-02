@tool
class_name LoggieEditorPlugin extends EditorPlugin

func _enter_tree():
	add_autoload_singleton(LoggieSettings.loggie_singleton_name, "res://addons/loggie/loggie.gd")
	add_loggie_project_settings()
	
func _enable_plugin() -> void:
	add_loggie_project_settings()

func _disable_plugin() -> void:
	var wipe_setting_exists = ProjectSettings.has_setting(LoggieSettings.project_settings.remove_settings_if_plugin_disabled.path)
	if (not wipe_setting_exists) or (wipe_setting_exists and ProjectSettings.get_setting(LoggieSettings.project_settings.remove_settings_if_plugin_disabled.path, true)):
		push_warning("The Loggie plugin is being disabled, and all of its ProjectSettings are erased from Godot. If you wish to prevent this behavior, look for the 'Project Settings -> Loggie -> General -> Remove Settings if Plugin Disabled' option while the plugin is enabled.")
		remove_loggie_project_setings()
	else:
		push_warning("The Loggie plugin is being disabled, but its ProjectSettings have been prevented from being removed from Godot. If you wish to allow that behavior, look for the 'Project Settings -> Loggie -> General -> Remove Settings if Plugin Disabled' option while the plugin is enabled.")
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
	if error != OK: 
		push_error("Loggie - Encountered error %d while saving project settings." % error)

## Adds a new project setting to Godot.
## TODO: Figure out how to also add the documentation to the ProjectSetting so that it shows up 
## in the Godot Editor tooltip when the setting is hovered over.
func add_project_setting(setting_name: String, default_value : Variant, value_type: int, type_hint: int = PROPERTY_HINT_NONE, hint_string: String = "", documentation : String = ""):
	if !ProjectSettings.has_setting(setting_name):
		ProjectSettings.set_setting(setting_name, default_value)
		
	ProjectSettings.set_initial_value(setting_name, default_value)
	ProjectSettings.add_property_info({	"name": setting_name, "type": value_type, "hint": type_hint, "hint_string": hint_string})
	ProjectSettings.set_as_basic(setting_name, true)

	var error: int = ProjectSettings.save()
	if error: 
		push_error("Loggie - Encountered error %d while saving project settings." % error)
