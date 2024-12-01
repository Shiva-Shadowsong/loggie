@tool

## Loggie is a basic logging utility for those who need common minor improvements and helpers around the basic [method print], [method print_rich]
## and other default Godot printing functions. Loggie creates instances of [LoggieMsg], which are a wrapper around a string that needs to manipulated,
## then uses them to properly format, arrange and present them in the console and .log files. Loggie uses the default Godot logging mechanism under the hood.
extends Node

## Stores a string describing the current version of Loggie.
const VERSION : String = "v1.5"

## Emitted any time Loggie attempts to log a message.
## Useful for capturing the messages that pass through Loggie.
## [br][param msg] is the message Loggie attempted to log (before any preprocessing).
## [br][param preprocessed_content] is what the string content of that message contained after the preprocessing step, 
## which is what ultimately gets logged.
## [br][param result] describes the final result of the attempt to log that message.
signal log_attempted(msg : LoggieMsg, preprocessed_content : String, result : LoggieEnums.LogAttemptResult)

## A reference to the settings of this Loggie. Read more about [LoggieSettings].
var settings : LoggieSettings

## Holds a mapping between all registered domains (string keys) and bool values representing whether
## those domains are currently enabled. Enable domains with [method set_domain_enabled].
## You can then place [LoggieMsg] messages into a domain by calling [method LoggieMsg.domain].
## Messages belonging to a disabled domain will never be outputted.
var domains : Dictionary = {}

## Holds a mapping between script paths and the names of the classes defined in those scripts.
var class_names : Dictionary = {}

func _init() -> void:
	var uses_original_settings_file = true
	var default_settings_path = get_script().get_path().get_base_dir().path_join("loggie_settings.gd")
	var custom_settings_path = get_script().get_path().get_base_dir().path_join("custom_settings.gd")
	
	if self.settings == null:
		if custom_settings_path != null and custom_settings_path != "" and ResourceLoader.exists(custom_settings_path):
			var loaded_successfully = load_settings_from_path(custom_settings_path)
			if loaded_successfully:
				uses_original_settings_file = false

	if uses_original_settings_file:
		var _settings = ResourceLoader.load(default_settings_path)
		if _settings != null:
			self.settings = _settings.new()
			self.settings.load()
		else:
			push_error("Loggie loaded neither a custom nor a default settings file. This will break the plugin. Make sure that a valid loggie_settings.gd is in the same directory where loggie.gd is.")
			return

	if self.settings.enforce_optimal_settings_in_release_build == true and is_in_production():
		self.settings.terminal_mode = LoggieEnums.TerminalMode.PLAIN
		self.settings.box_characters_mode = LoggieEnums.BoxCharactersMode.COMPATIBLE

	# Already cache the name of the singleton found at loggie's script path.
	class_names[self.get_script().resource_path] = LoggieSettings.loggie_singleton_name
	
	# Prepopulate class data from ProjectSettings to avoid needing to read files.
	if self.settings.derive_and_show_class_names == true and OS.has_feature("debug"):
		for class_data: Dictionary in ProjectSettings.get_global_class_list():
			class_names[class_data.path] = class_data.class
	  
		for autoload_setting: String in ProjectSettings.get_property_list().map(func(prop): return prop.name).filter(func(prop): return prop.begins_with("autoload/") and ProjectSettings.has_setting(prop)):
			var autoload_class: String = autoload_setting.trim_prefix("autoload/")
			var class_path: String = ProjectSettings.get_setting(autoload_setting)
			class_path = class_path.trim_prefix("*")      
			if not class_names.has(class_path):
				class_names[class_path] = autoload_class

	# Don't print Loggie boot messages if Loggie is running only from the editor.
	if Engine.is_editor_hint():
		return
	
	if self.settings.show_loggie_specs != LoggieEnums.ShowLoggieSpecsMode.DISABLED:
		msg("👀 Loggie {version} booted.".format({"version" : self.VERSION})).color(Color.ORANGE).header().nl().info()
		var loggie_specs_msg = LoggieSystemSpecsMsg.new().use_logger(self)
		loggie_specs_msg.add(msg("|\t Using Custom Settings File: ").bold(), !uses_original_settings_file).nl().add("|\t ").hseparator(35).nl()
		
		match self.settings.show_loggie_specs:
			LoggieEnums.ShowLoggieSpecsMode.ESSENTIAL:
				loggie_specs_msg.embed_essential_logger_specs()
			LoggieEnums.ShowLoggieSpecsMode.ADVANCED:
				loggie_specs_msg.embed_advanced_logger_specs()

		loggie_specs_msg.preprocessed(false).info()

	if self.settings.show_system_specs:
		var system_specs_msg = LoggieSystemSpecsMsg.new().use_logger(self)
		system_specs_msg.embed_specs().preprocessed(false).info()

## Attempts to instantiate a LoggieSettings object from the script at the given [param path].
## Returns true if successful, otherwise false and prints an error.
func load_settings_from_path(path : String) -> bool:
	var settings_resource = ResourceLoader.load(path)
	var settings_instance

	if settings_resource != null:
		settings_instance = settings_resource.new()

	if (settings_instance is LoggieSettings):
		self.settings = settings_instance
		self.settings.load()
		return true
	else:
		push_error("Unable to instantiate a LoggieSettings object from the script at path {path}. Check that loggie.gd -> custom_settings_path is pointing to a valid .gd script that contains the class definition of a class that either extends LoggieSettings, or is LoggieSettings.".format({"path": path}))
		return false

## Checks if Loggie is running in production (release) mode of the game.
## While it is, every [LoggieMsg] will have plain output.
## Uses a sensible default check for most projects, but
## you can rewrite this function to your needs if necessary.
func is_in_production() -> bool:
	return OS.has_feature("release")

## Sets whether the domain with the given name is enabled.
func set_domain_enabled(domain_name : String, enabled : bool) -> void:
	domains[domain_name] = enabled

## Checks whether the domain with the given name is enabled.
## The domain name "" (empty string) is the default one for all newly created messages,
## and is designed to always be enabled.
func is_domain_enabled(domain_name : String) -> bool:
	if domain_name == "":
		return true
	
	if domains.has(domain_name) and domains[domain_name] == true:
		return true
	
	return false

## Creates a new [LoggieMsg] out of the given [param msg] and extra arguments (by converting them to strings and concatenating them to the msg).
## You may continue to modify the [LoggieMsg] with additional functions from that class, then when you are ready to output it, use methods like:
## [method LoggieMsg.info], [method LoggieMsg.warn], etc.
func msg(message = "", arg1 = null, arg2 = null, arg3 = null, arg4 = null, arg5 = null) -> LoggieMsg:
	var loggieMsg = LoggieMsg.new(message, arg1, arg2, arg3, arg4, arg5)
	loggieMsg.use_logger(self)
	return loggieMsg

## A shortcut method that instantly creates a [LoggieMsg] with the given arguments and outputs it at the info level.
## Can be used when you have no intention of customizing a LoggieMsg in any way using helper methods.
## For customization, use [method msg] instead.
func info(message = "", arg1 = null, arg2 = null, arg3 = null, arg4 = null, arg5 = null) -> LoggieMsg:
	return msg(message, arg1, arg2, arg3, arg4, arg5).info()

## A shortcut method that instantly creates a [LoggieMsg] with the given arguments and outputs it at the warn level.
## Can be used when you have no intention of customizing a LoggieMsg in any way using helper methods.
## For customization, use [method msg] instead.
func warn(message = "", arg1 = null, arg2 = null, arg3 = null, arg4 = null, arg5 = null) -> LoggieMsg:
	return msg(message, arg1, arg2, arg3, arg4, arg5).warn()

## A shortcut method that instantly creates a [LoggieMsg] with the given arguments and outputs it at the error level.
## Can be used when you have no intention of customizing a LoggieMsg in any way using helper methods.
## For customization, use [method msg] instead.
func error(message = "", arg1 = null, arg2 = null, arg3 = null, arg4 = null, arg5 = null) -> LoggieMsg:
	return msg(message, arg1, arg2, arg3, arg4, arg5).error()

## A shortcut method that instantly creates a [LoggieMsg] with the given arguments and outputs it at the debug level.
## Can be used when you have no intention of customizing a LoggieMsg in any way using helper methods.
## For customization, use [method msg] instead.
func debug(message = "", arg1 = null, arg2 = null, arg3 = null, arg4 = null, arg5 = null) -> LoggieMsg:
	return msg(message, arg1, arg2, arg3, arg4, arg5).debug()

## A shortcut method that instantly creates a [LoggieMsg] with the given arguments and outputs it at the notice level.
## Can be used when you have no intention of customizing a LoggieMsg in any way using helper methods.
## For customization, use [method msg] instead.
func notice(message = "", arg1 = null, arg2 = null, arg3 = null, arg4 = null, arg5 = null) -> LoggieMsg:
	return msg(message, arg1, arg2, arg3, arg4, arg5).notice()
