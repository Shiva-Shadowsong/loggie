@tool

## Loggie is a basic logging utility for those who need common minor improvements and helpers around the basic [method print], [method print_rich]
## and other default Godot printing functions. Loggie creates instances of [LoggieMsg], which are a wrapper around a string that needs to manipulated,
## then uses them to properly format, arrange and present them in the console and .log files. Loggie uses the default Godot logging mechanism under the hood.
extends Node

## Stores a string describing the current version of Loggie.
const VERSION : String = "v1.1"

## A reference to the settings of this Loggie. Read more about [LoggieSettings].
var settings : LoggieSettings

## Holds a mapping between all registered domains (string keys) and bool values representing whether
## those domains are currently enabled. Enable domains with [method set_domain_enabled].
## You can then place [LoggieMsg] messages into a domain by calling [method LoggieMsg.domain].
## Messages belonging to a disabled domain will never be outputted.
var domains : Dictionary = {}

## Holds a mapping between script paths and the names of the classes defined in those scripts.
var class_names : Dictionary = {}

func _ready() -> void:
	if Engine.is_editor_hint():
		return

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

	var bootMsg = msg("[color=orange]👀 Loggie {version} booted.[/color]".format({"version" : self.VERSION}))
	bootMsg.useLogger(self).header().nl()
	bootMsg.add("[b]Terminal Mode:[/b]", LoggieTools.TerminalMode.keys()[settings.terminal_mode]).suffix(" - ")
	bootMsg.add("[b]Log Level:[/b]", LoggieTools.LogLevel.keys()[settings.log_level]).suffix(" - ")
	bootMsg.add("[b]Is in Production:[/b]", self.is_in_production()).suffix(" - ")
	bootMsg.add("[b]Box Characters Mode:[/b]", LoggieTools.BoxCharactersMode.keys()[settings.box_characters_mode]).nl()
	bootMsg.add("[b]Using Custom Settings File:[/b]", !uses_original_settings_file).nl()
	bootMsg.preprocessed(false).info()
	
	if settings.show_system_specs:
		var systemSpecsMsg = LoggieSystemSpecsMsg.new().useLogger(self)
		systemSpecsMsg.embed_specs().preprocessed(false).info()

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
func msg(msg = "", arg1 = null, arg2 = null, arg3 = null, arg4 = null, arg5 = null) -> LoggieMsg:
	var loggieMsg = LoggieMsg.new(msg, arg1, arg2, arg3, arg4, arg5)
	loggieMsg.useLogger(self)
	return loggieMsg

