@tool

## Defines a set of variables through which all the relevant settings of Loggie can have their
## values set, read and documented. An instance of this class is found in [member Loggie.settings], and that's where Loggie
## ultimately reads from when it's asking for the value of a setting. For user convenience, settings are (by default) exported
## as custom Godot project settings and are loaded from there into these variables during [method load], however,
## you can extend or overwrite this class' [method load] method to define a different way of loading these settings if you prefer.
## [i](e.g. loading from a config.ini file, or a .json file, etc.)[/i].[br][br]
## 
## Loggie calls [method load] on this class during its [method _ready] function.
class_name LoggieSettings extends Resource

## The name that will be used for the singleton referring to Loggie.
## [br][br][i][b]Note:[/b] You may change this to something you're more used to, such as "log" or "logger".[/i]
## When doing so, make sure to either do it while the Plugin is enabled, then disable and re-enable the plugin,
## or that you manually clear out the previously created autoload (should be called "Loggie") in Project Settings -> Autoloads.
static var loggie_singleton_name = "Loggie"

## The dictionary which is used to grab the defaults and other values associated with each setting
## relevant to Loggie, particularly important for the default way of loading [LoggieSettings] and
## setting up Godot Project Settings related to Loggie.
const project_settings = {
	"remove_settings_if_plugin_disabled" = {
		"path": "loggie/general/remove_settings_if_plugin_disabled",
		"default_value" : true,
		"type" : TYPE_BOOL,
		"hint" : PROPERTY_HINT_NONE,
		"hint_string" : "",
		"doc" : "Choose whether you want Loggie project settings to be wiped from ProjectSettings if the Loggie plugin is disabled.",
	},
	"terminal_mode" = {
		"path": "loggie/general/terminal_mode",
		"default_value" : LoggieEnums.TerminalMode.BBCODE,
		"type" : TYPE_INT,
		"hint" : PROPERTY_HINT_ENUM,
		"hint_string" : "Plain:0,ANSI:1,BBCode:2",
		"doc" : "Choose the terminal for which loggie should preprocess the output so that it displays as intended.[br][br]Use BBCode for Godot console.[br]Use ANSI for Powershell, Bash, etc.[br]Use PLAIN for log files.",
	},
	"log_level" = {
		"path": "loggie/general/log_level",
		"default_value" : LoggieEnums.LogLevel.INFO,
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
	"show_loggie_specs" = {
		"path": "loggie/general/show_loggie_specs",
		"default_value" : LoggieEnums.ShowLoggieSpecsMode.ESSENTIAL,
		"type" : TYPE_INT,
		"hint" : PROPERTY_HINT_ENUM,
		"hint_string" : "Disabled:0,Essential:1,Advanced:2",
		"doc" : "Defines which way Loggie should print its own specs when it is booted.",
	},
	"enforce_optimal_settings_in_release_build" = {
		"path": "loggie/general/enforce_optimal_settings_in_release_build",
		"default_value" : true,
		"type" : TYPE_BOOL,
		"hint" : PROPERTY_HINT_NONE,
		"hint_string" : "",
		"doc" : "Should Loggie enforce certain settings to automatically change to optimal values in production/release builds?",
	},
	"output_timestamps" = {
		"path": "loggie/timestamps/output_timestamps",
		"default_value" : false,
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
	"output_message_domain" = {
		"path": "loggie/preprocessing/output_message_domain",
		"default_value" : false,
		"type" : TYPE_BOOL,
		"hint" : PROPERTY_HINT_NONE,
		"hint_string" : "",
		"doc" : "If true, logged messages will have the domain they are coming from prepended to them.",
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
		"default_value" : false,
		"type" : TYPE_BOOL,
		"hint" : PROPERTY_HINT_NONE,
		"hint_string" : "",
		"doc" : "If true, Loggie will attempt to find out the name of the main class from which the log line is coming and append it in front of the message.",
	},
	"nameless_class_name_proxy" = {
		"path": "loggie/preprocessing/nameless_class_name_proxy",
		"default_value" : LoggieEnums.NamelessClassExtensionNameProxy.BASE_TYPE,
		"type" : TYPE_INT,
		"hint" : PROPERTY_HINT_ENUM,
		"hint_string" : "Nothing:0,ScriptName:1,BaseType:2",
		"doc" : "If 'Derive and Display Class Names From Scripts' is enabled, and a script doesn't have a 'class_name', which text should we use as a substitute?",
	},
	"format_timestamp" = {
		"path": "loggie/formats/timestamp",
		"default_value" : "[{day}.{month}.{year} {hour}:{minute}:{second}]",
		"type" : TYPE_STRING,
		"hint" : PROPERTY_HINT_NONE,
		"hint_string" : "",
		"doc" : "The format used for timestamps which are prepended to the message when output_timestamps is enabled.",
	},
	"format_debug_msg" = {
		"path": "loggie/formats/debug_message",
		"default_value" : "[b][color=pink][DEBUG]:[/color][/b] {msg}",
		"type" : TYPE_STRING,
		"hint" : PROPERTY_HINT_NONE,
		"hint_string" : "",
		"doc" : "The format used for debug messages.",
	},
	"format_info_msg" = {
		"path": "loggie/formats/info_message",
		"default_value" : "{msg}",
		"type" : TYPE_STRING,
		"hint" : PROPERTY_HINT_NONE,
		"hint_string" : "",
		"doc" : "The format used for info messages.",
	},
	"format_notice_msg" = {
		"path": "loggie/formats/notice_message",
		"default_value" : "[b][color=cyan][NOTICE]:[/color][/b] {msg}",
		"type" : TYPE_STRING,
		"hint" : PROPERTY_HINT_NONE,
		"hint_string" : "",
		"doc" : "The format used for notice messages.",
	},
	"format_warning_msg" = {
		"path": "loggie/formats/warning_message",
		"default_value" : "[b][color=orange][WARN]:[/color][/b] {msg}",
		"type" : TYPE_STRING,
		"hint" : PROPERTY_HINT_NONE,
		"hint_string" : "",
		"doc" : "The format used for warning messages.",
	},
	"format_error_msg" = {
		"path": "loggie/formats/error_message",
		"default_value" : "[b][color=red][ERROR]:[/color][/b] {msg}",
		"type" : TYPE_STRING,
		"hint" : PROPERTY_HINT_NONE,
		"hint_string" : "",
		"doc" : "The format used for error messages.",
	},
	"format_domain_prefix" = {
		"path": "loggie/formats/domain_prefix",
		"default_value" : "[b]({domain})[/b] {msg}",
		"type" : TYPE_STRING,
		"hint" : PROPERTY_HINT_NONE,
		"hint_string" : "",
		"doc" : "The format used for domain prefixes.",
	},
	"format_header" = {
		"path": "loggie/formats/header",
		"default_value" : "[b][i]{msg}[/i][/b]",
		"type" : TYPE_STRING,
		"hint" : PROPERTY_HINT_NONE,
		"hint_string" : "",
		"doc" : "The format used for headers.",
	},
	"h_separator_symbol" = {
		"path": "loggie/formats/h_separator_symbol",
		"default_value" : "-",
		"type" : TYPE_STRING,
		"hint" : PROPERTY_HINT_NONE,
		"hint_string" : "",
		"doc" : "The symbol used for the horizontal separator.",
	},
	"box_characters_mode" = {
		"path": "loggie/formats/box_characters_mode",
		"default_value" : LoggieEnums.BoxCharactersMode.COMPATIBLE,
		"type" : TYPE_INT,
		"hint" : PROPERTY_HINT_ENUM,
		"hint_string" : "Compatible:0,Pretty:1",
		"doc" : "There are two sets of box characters defined in LoggieSettings - one set contains prettier characters that produce a nicer looking box, but may not render correctly in the context of various terminals. The other set contains characters that produce a less pretty box, but are compatible with being shown in most terminals.",
	},
}

## The current terminal mode of Loggie.
## Terminal mode determines whether BBCode, ANSI or some other type of
## formatting is used to convey text effects, such as bold, italic, colors, etc.
## [br][br]BBCode is compatible with the Godot console.
## [br]ANSI is compatible with consoles like Powershell and Windows CMD.
## [br]PLAIN is used to strip any effects and use plain text instead, which is good for saving raw logs into log files.
var terminal_mode : LoggieEnums.TerminalMode

## The current log level of Loggie.
## It determines which types of messages are allowed to be logged.
## Set this using [method setLogLevel].
var log_level : LoggieEnums.LogLevel

## Whether or not Loggie should log the loggie specs on ready.
var show_loggie_specs : LoggieEnums.ShowLoggieSpecsMode

## Whether or not Loggie should log the system specs on ready.
var show_system_specs : bool

## If true, the domain from which the [LoggieMsg] is coming will be prepended to the output.
## If the domain is default (empty), nothing will change.
var output_message_domain : bool

## Whether to, in addition to logging errors with [method push_error], 
## Loggie should also print the error as a message in the standard output.
var print_errors_to_console : bool

## Whether to, in addition to logging errors with [method push_warning], 
## Loggie should also print the error as a message in the standard output.
var print_warnings_to_console : bool

## If true, instead of [method print], [method print_debug] will be 
## used when printing messages with [method LoggieMsg.debug].
var use_print_debug_for_debug_msg : bool

## Whether Loggie should use the scripts from which it is being called to 
## figure out a class name for the class that called a loggie function,
## and display it at the start of each output message.
## This only works in debug builds because it uses [method @GDScript.get_stack]. 
## See that method's documentation to see why that can't be used in release builds.
var derive_and_show_class_names : bool

## Defines which text will be used as a substitute for the 'class_name' of scripts that do not have a 'class_name'.
## Relevant only if [member derive_and_show_class_names] is enabled.
var nameless_class_name_proxy : LoggieEnums.NamelessClassExtensionNameProxy

## Whether Loggie should prepend a timestamp to each output message.
var output_timestamps : bool

## Whether the outputted timestamps (if [member output_timestamps] is enabled) use UTC or local machine time.
var timestamps_use_utc : bool

## Whether Loggie should enforce optimal values for certain settings when in a Release/Production build.
## [br]If true, Loggie will enforce:
## [br]  * [member terminal_mode] to [member LoggieEnums.TerminalMode.PLAIN]
## [br]  * [member box_characters_mode] to [member LoggieEnums.BoxCharactersMode.COMPATIBLE]
var enforce_optimal_settings_in_release_build : bool

# ----------------------------------------------- #
#region Formats for prints
# ----------------------------------------------- #
# As per the `print_rich` documentation, supported colors are: black, red, green, yellow, blue, magenta, pink, purple, cyan, white, orange, gray.
# Any other color will be displayed in the Godot console or an ANSI based console, but the color tag (in case of BBCode) won't be properly stripped
# when written to the .log file, resulting in BBCode visible in .log files.

## The format used to decorate a message as a header when using [method LoggieMsg.header].[br]
## The [param {msg}] is a variable that will be replaced with the contents of the message.[br]
var format_header = "[b][i]{msg}[/i][/b]"

## The format used when appending a domain to a message.[br]
## See: [member output_message_domain]
## The [param {msg}] is a variable that will be replaced with the contents of the message.[br]
## The [param {domain}] is a variable that will be replaced with the domain key.[br]
## You can customize this in your ProjectSettings, or custom_settings.gd (if using it).[br]
var format_domain_prefix = "[b]({domain})[/b] {msg}"

## The format used when outputting error messages.[br]
## The [param {msg}] is a variable that will be replaced with the contents of the message.[br]
## You can customize this in your ProjectSettings, or custom_settings.gd (if using it).[br]
var format_error_msg = "[b][color=red][ERROR]:[/color][/b] {msg}"

## The format used when outputting warning messages.[br]
## The [param {msg}] is a variable that will be replaced with the contents of the message.[br]
## You can customize this in your ProjectSettings, or custom_settings.gd (if using it).[br]
var format_warning_msg = "[b][color=orange][WARN]:[/color][/b] {msg}"

## The format used when outputting notice messages.[br]
## The [param {msg}] is a variable that will be replaced with the contents of the message.[br]
## You can customize this in your ProjectSettings, or custom_settings.gd (if using it).[br]
var format_notice_msg = "[b][color=cyan][NOTICE]:[/color][/b] {msg}"

## The format used when outputting info messages.[br]
## The [param {msg}] is a variable that will be replaced with the contents of the message.[br]
## You can customize this in your ProjectSettings, or custom_settings.gd (if using it).[br]
var format_info_msg = "{msg}"

## The format used when outputting debug messages.[br]
## The [param {msg}] is a variable that will be replaced with the contents of the message.[br]
## You can customize this in your ProjectSettings, or custom_settings.gd (if using it).[br]
var format_debug_msg = "[b][color=pink][DEBUG]:[/color][/b] {msg}"

## The format used for timestamps which are prepended to the message when [member output_timestamps] is enabled.[br]
## The variables [param {day}], [param {month}], [param {year}], [param {hour}], [param {minute}], [param {second}], [param {weekday}], and [param {dst}] are supported.
## You can customize this in your ProjectSettings, or custom_settings.gd (if using it).[br]
var format_timestamp = "[{day}.{month}.{year} {hour}:{minute}:{second}]"

## The symbol which will be used for the HSeparator.
var h_separator_symbol = "-"

## The mode used for drawing boxes.
var box_characters_mode : LoggieEnums.BoxCharactersMode

## The symbols which will be used to construct a box decoration that will properly
## display on any kind of terminal or text reader.
## For a prettier but potentially incompatible box, use [member box_symbols_pretty] instead.
var box_symbols_compatible = {
	# ANSI and .log compatible box characters:
	"top_left" : "-",
	"top_right" : "-",
	"bottom_left" : "-",
	"bottom_right" : "-",
	"h_line" : "-",
	"v_line" : ":",
}

## The symbols which will be used to construct pretty box decoration.
## These may not be compatible with some terminals or text readers.
## Use the [member box_symbols_compatible] instead as an alternative.
var box_symbols_pretty = {
	"top_left" : "┌",
	"top_right" : "┐",
	"bottom_left" : "└",
	"bottom_right" : "┘",
	"h_line" : "─",
	"v_line" : "│",
}

#endregion
# ----------------------------------------------- #

## Loads the initial (default) values for all of the LoggieSettings variables.
## (By default, loads them from ProjectSettings (if any modifications there exist), 
## or looks in [LoggieEditorPlugin..project_settings] for default values).
## [br][br]Extend this class and override this function to write your own logic for 
## how loggie should obtain these settings if you have a need for a different approach.
func load():
	terminal_mode = ProjectSettings.get_setting(project_settings.terminal_mode.path, project_settings.terminal_mode.default_value)
	log_level = ProjectSettings.get_setting(project_settings.log_level.path, project_settings.log_level.default_value)
	show_loggie_specs = ProjectSettings.get_setting(project_settings.show_loggie_specs.path, project_settings.show_loggie_specs.default_value)
	show_system_specs = ProjectSettings.get_setting(project_settings.show_system_specs.path, project_settings.show_system_specs.default_value)
	output_timestamps = ProjectSettings.get_setting(project_settings.output_timestamps.path, project_settings.output_timestamps.default_value)
	timestamps_use_utc = ProjectSettings.get_setting(project_settings.timestamps_use_utc.path, project_settings.timestamps_use_utc.default_value)
	enforce_optimal_settings_in_release_build = ProjectSettings.get_setting(project_settings.enforce_optimal_settings_in_release_build.path, project_settings.enforce_optimal_settings_in_release_build.default_value)

	print_errors_to_console = ProjectSettings.get_setting(project_settings.output_errors_to_console.path, project_settings.output_errors_to_console.default_value)
	print_warnings_to_console = ProjectSettings.get_setting(project_settings.output_warnings_to_console.path, project_settings.output_warnings_to_console.default_value)
	use_print_debug_for_debug_msg = ProjectSettings.get_setting(project_settings.use_print_debug_for_debug_msgs.path, project_settings.use_print_debug_for_debug_msgs.default_value)

	output_message_domain = ProjectSettings.get_setting(project_settings.output_message_domain.path, project_settings.output_message_domain.default_value)
	derive_and_show_class_names = ProjectSettings.get_setting(project_settings.derive_and_display_class_names_from_scripts.path, project_settings.derive_and_display_class_names_from_scripts.default_value)
	
	nameless_class_name_proxy = ProjectSettings.get_setting(project_settings.nameless_class_name_proxy.path, project_settings.nameless_class_name_proxy.default_value)
	box_characters_mode = ProjectSettings.get_setting(project_settings.box_characters_mode.path, project_settings.box_characters_mode.default_value)

	format_timestamp = ProjectSettings.get_setting(project_settings.format_timestamp.path, project_settings.format_timestamp.default_value)
	format_info_msg = ProjectSettings.get_setting(project_settings.format_info_msg.path, project_settings.format_info_msg.default_value)
	format_notice_msg = ProjectSettings.get_setting(project_settings.format_notice_msg.path, project_settings.format_notice_msg.default_value)
	format_warning_msg = ProjectSettings.get_setting(project_settings.format_warning_msg.path, project_settings.format_warning_msg.default_value)
	format_error_msg = ProjectSettings.get_setting(project_settings.format_error_msg.path, project_settings.format_error_msg.default_value)
	format_debug_msg = ProjectSettings.get_setting(project_settings.format_debug_msg.path, project_settings.format_debug_msg.default_value)
	h_separator_symbol = ProjectSettings.get_setting(project_settings.h_separator_symbol.path, project_settings.h_separator_symbol.default_value)

## Returns a dictionary where the indices are names of relevant variables in the LoggieSettings class,
## and the values are their current values.
func to_dict() -> Dictionary:
	var dict = {}
	var included = [
		"terminal_mode", "log_level", "show_loggie_specs", "show_system_specs", "enforce_optimal_settings_in_release_build",
		"output_message_domain", "print_errors_to_console", "print_warnings_to_console",
		"use_print_debug_for_debug_msg", "derive_and_show_class_names", "nameless_class_name_proxy",
		"output_timestamps", "timestamps_use_utc", "format_header", "format_domain_prefix", "format_error_msg",
		"format_warning_msg", "format_notice_msg", "format_info_msg", "format_debug_msg", "format_timestamp",
		"h_separator_symbol", "box_characters_mode", "box_symbols_compatible", "box_symbols_pretty",
	]
	
	for var_name in included:
		dict[var_name] = get(var_name)
	return dict
