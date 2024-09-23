@tool
## Loggie is a basic logging utility for those who need common minor improvements and helpers around the basic [method print], [method print_rich]
## and other default Godot printing functions. Loggie creates instances of [LoggieMsg], which are a wrapper around a string that needs to manipulated,
## then uses them to properly format, arrange and present them in the console and .log files. Loggie uses the default Godot logging mechanism under the hood.
extends Node

## Stores a string describing the current version of Loggie.
const VERSION : String = "v1.0"

## A reference to the settings of this Loggie. Access and modify them through this variable.
var settings : LoggieSettings

## The path to the script from which a LoggieSettings instance can be instantiated.
## You may override this to point at your custom loggie_settings.
## If left as empty string, this is ignored.
const custom_settings_path : String = "" # e.g. res://custom_loggie_settings.gd

## The path to the script from which a LoggieSettings instance can be instantiated.
## This is used by default if `CustomSettingsPath` is null.
const default_settings_path : String = "res://addons/loggie/loggie_settings.gd"

## Holds a mapping between all registered domains (string keys) and bool values representing whether
## those domains are currently enabled. Enable domains with [method set_domain_enabled].
## You can then place [LoggieMsg] messages into a domain by calling [method LoggieMsg.domain].
## Messages belonging to a disabled domain will never be outputted.
var domains : Dictionary = {}

## Holds a mapping between script paths and the names of the classes defined in those scripts.
var classNames : Dictionary = {}

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	var uses_original_settings_file = true

	if settings == null:
		if custom_settings_path != null and custom_settings_path != "":
			var settings_resource = ResourceLoader.load(custom_settings_path)
			var settings_instance
	
			if settings_resource != null:
				settings_instance = settings_resource.new()
	
			if (settings_instance is LoggieSettings):
				self.settings = settings_instance
				uses_original_settings_file = false
			else:
				push_error("Unable to instantiate a LoggieSettings object from the script at path custom_settings_path => {path}. Will use the default loggie_settings.gd instead.".format({"path": custom_settings_path}))
				
	if uses_original_settings_file:
		settings = ResourceLoader.load(default_settings_path).new()
		settings.load()
	
	var bootMsg = msg("[color=orange]👀 Loggie {version} booted.[/color]".format({"version" : self.VERSION})).header().nl()
	bootMsg.append("[b]Terminal Mode:[/b]", LoggieTools.TerminalMode.keys()[settings.terminal_mode]).suffix(" - ")
	bootMsg.append("[b]Log Level:[/b]", LoggieTools.LogLevel.keys()[settings.log_level]).suffix(" - ")
	bootMsg.append("[b]Is in Production:[/b]", self.is_in_production()).suffix(" - ")
	bootMsg.append("[b]Box Characters Mode:[/b]", LoggieTools.BoxCharactersMode.keys()[settings.box_characters_mode]).nl()
	bootMsg.append("[b]Using Custom Settings File:[/b]", !uses_original_settings_file).nl()
	bootMsg.preprocessed(false).info()
	
	if settings.show_system_specs:
		LoggieSystemSpecsMsg.new().embed_specs().preprocessed(false).info()

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
	return LoggieMsg.new(msg, arg1, arg2, arg3, arg4, arg5)

