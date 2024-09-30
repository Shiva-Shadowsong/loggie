@tool
## Defines a set of variables through which all the relevant settings of Loggie can have their
## values set, read and documented. An instance of this class is found in [member Loggie.settings], and that's where Loggie
## ultimately reads from when it's asking for the value of a setting. For user convenience, settings are (by default) exported
## as custom Godot project settings and are loaded from there into these variables during [method load], however,
## you can extend or overwrite this class' [method load] method to define a different way of loading these settings if you prefer.
## [i](e.g. loading from a config.ini file, or a .json file, etc.)[/i].[br][br]
## 
## Loggie calls [method load] on this class during its [method _ready] function.
class_name LoggieSettings extends Node

## The current terminal mode of Loggie.
## Terminal mode determines whether BBCode, ANSI or some other type of
## formatting is used to convey text effects, such as bold, italic, colors, etc.
## [br][br]BBCode is compatible with the Godot console.
## [br]ANSI is compatible with consoles like Powershell and Windows CMD.
## [br]PLAIN is used to strip any effects and use plain text instead, which is good for saving raw logs into log files.
var terminal_mode : LoggieTools.TerminalMode

## The current log level of Loggie.
## It determines which types of messages are allowed to be logged.
## Set this using [method setLogLevel].
var log_level : LoggieTools.LogLevel

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
## used when printing messages with [method LogMsg.debug].
var use_print_debug_for_debug_msg : bool

## Whether Loggie should use the scripts from which it is being called to 
## figure out a class name for the class that called a loggie function,
## and display it at the start of each output message.
var derive_and_show_class_names

## Whether Loggie should prepend a timestamp to each output message.
var show_timestamps

## Whether the outputted timestamps (if [member show_timestamps] is enabled) use UTC or local machine time.
var timestamps_use_utc

# ----------------------------------------------- #
#region Formats for prints
# ----------------------------------------------- #
# As per the `print_rich` documentation, supported colors are: black, red, green, yellow, blue, magenta, pink, purple, cyan, white, orange, gray.
# Any other color will be displayed in the Godot console or an ANSI based console, but the color tag (in case of BBCode) won't be properly stripped
# when written to the .log file, resulting in BBCode visible in .log files.

## Formatting of headers generated with [method LoggieMsg.header].
var format_header = "[b][i]%s[/i][/b]"

## Formatting of the domain if it is set to be outputted for messages that come from domains.
var format_domain_prefix = "[b](%s)[/b] %s"

## The Formatting of a error message.
var format_error_msg = "[b][color=red][ERROR]:[/color][/b] %s"

## The Formatting of a warning message.
var format_warning_msg = "[b][color=orange][WARN]:[/color][/b] %s"

## The Formatting of a notice message.
var format_notice_msg = "[b][color=cyan][NOTICE]:[/color][/b] %s"

## The Formatting of an info message.
var format_info_msg = "%s"

## The Formatting of a debug message.
var format_debug_msg = "[b][color=pink][DEBUG]:[/color][/b] %s"

## The symbol which will be used for the HSeparator.
var h_separator_symbol = "-"

## The mode used for drawing boxes.
var box_characters_mode : LoggieTools.BoxCharactersMode

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
	const loggie_p_settings = LoggieEditorPlugin.project_settings

	terminal_mode = ProjectSettings.get_setting(loggie_p_settings.terminal_mode.path, loggie_p_settings.terminal_mode.default_value)
	log_level = ProjectSettings.get_setting(loggie_p_settings.log_level.path, loggie_p_settings.log_level.default_value)
	show_system_specs = ProjectSettings.get_setting(loggie_p_settings.show_system_specs.path, loggie_p_settings.show_system_specs.default_value)
	show_timestamps = ProjectSettings.get_setting(loggie_p_settings.output_timestamps.path, loggie_p_settings.output_timestamps.default_value)
	timestamps_use_utc = ProjectSettings.get_setting(loggie_p_settings.timestamps_use_utc.path, loggie_p_settings.timestamps_use_utc.default_value)

	print_errors_to_console = ProjectSettings.get_setting(loggie_p_settings.output_errors_to_console.path, loggie_p_settings.output_errors_to_console.default_value)
	print_warnings_to_console = ProjectSettings.get_setting(loggie_p_settings.output_warnings_to_console.path, loggie_p_settings.output_warnings_to_console.default_value)
	use_print_debug_for_debug_msg = ProjectSettings.get_setting(loggie_p_settings.use_print_debug_for_debug_msgs.path, loggie_p_settings.use_print_debug_for_debug_msgs.default_value)

	output_message_domain = ProjectSettings.get_setting(loggie_p_settings.output_message_domain.path, loggie_p_settings.output_message_domain.default_value)
	derive_and_show_class_names = ProjectSettings.get_setting(loggie_p_settings.derive_and_display_class_names_from_scripts.path, loggie_p_settings.derive_and_display_class_names_from_scripts.default_value)
	box_characters_mode = ProjectSettings.get_setting(loggie_p_settings.box_characters_mode.path, loggie_p_settings.box_characters_mode.default_value)
