@tool
extends Node

## A data class keeping track of all of the current settings of Loggie.
## These value of many settings here can be set through the Project > Project Settings > Loggie menu.
## If you wish to adjust the format in which certain messages are outputted, go to the "Formats for prints" region
## in this script, and adjust there.
class_name LoggieSettings

## The current terminal mode of Loggie.
## Terminal mode determines whether BBCode, ANSI or some other type of formatting is used to
## convey text effects, such as bold, italic, colors, etc.[br]
## [br]BBCode is compatible with the Godot console.
## [br]ANSI is compatible with consoles like Powershell and Windows CMD.
## [br]PLAIN is used to strip any effects and use plain text instead, which is good for saving raw logs into log files.
var terminal_mode : LoggieTools.TerminalMode = LoggieTools.TerminalMode.BBCODE

## The current log level of Loggie.
## It determines which types of messages are allowed to be logged.
## Set this using [method setLogLevel].
var log_level : LoggieTools.LogLevel = LoggieTools.LogLevel.DEBUG

## Whether or not Loggie should log the system specs on ready.
var show_system_specs : bool = true

## If true, the domain from which the [LoggieMsg] is coming will be prepended to the output.
## If the domain is default (empty), nothing will change.
var output_message_domain : bool = true

## Whether to, in addition to logging errors with [method push_error], Loggie should also print the error as a message
## in the standard output.
var print_errors_to_console : bool = true

## Whether to, in addition to logging errors with [method push_warning], Loggie should also print the error as a message
## in the standard output.
var print_warnings_to_console : bool = true

## If true, instead of [method print], [method print_debug] will be used when printing messages with [method LogMsg.debug].
var use_print_debug_for_debug_msg : bool = false

## Whether Loggie should use the scripts from which it is being called to figure out a class name for the class
## that called a loggie function, and display it at the start of each output message.
var derive_and_show_class_names = true

## Whether Loggie should prepend a timestamp to each output message.
var show_timestamps = true

## Whether the outputted timestamps (if [member show_timestamps] is enabled) use UTC or local machine time.
var timestamps_use_utc = true

# ----------------------------------------------- #
#region Formats for prints
# ----------------------------------------------- #
# Supported colors are: black, red, green, yellow, blue, magenta, pink, purple, cyan, white, orange, gray.
# As per the `print_rich` documentation. Any other color will be displayed in Godot, but won't be properly stripped
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
var box_characters_mode : LoggieTools.BoxCharactersMode = LoggieTools.BoxCharactersMode.COMPATIBLE

## The symbols which will be used to construct a box decoration that will properly
## display on any kind of terminal or text reader.
## For a prettier but potentially incompatible box, use box_symbols_pretty instead.
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
## Use the box_symbols_compatible instead as an alternative.
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

## Loads the values for the setting variables from ProjectSettings.
## If you wish to overwrite this behavior, please read [member Loggie.custom_settings_path].
func load():
	terminal_mode = ProjectSettings.get_setting("Loggie/TerminalMode", self.terminal_mode)
	log_level = ProjectSettings.get_setting("Loggie/LogLevel", self.log_level)
	show_system_specs = ProjectSettings.get_setting("Loggie/ShowSystemSpecs", self.show_system_specs)
	output_message_domain = ProjectSettings.get_setting("Loggie/OutputMessageDomain", self.output_message_domain)
	print_errors_to_console = ProjectSettings.get_setting("Loggie/OutputErrorsAlsoToConsole", self.print_errors_to_console)
	print_warnings_to_console = ProjectSettings.get_setting("Loggie/OutputWarningsAlsoToConsole", self.print_warnings_to_console)
	use_print_debug_for_debug_msg = ProjectSettings.get_setting("Loggie/UsePrintDebugForDebugMessages", self.use_print_debug_for_debug_msg)
	derive_and_show_class_names = ProjectSettings.get_setting("Loggie/DeriveAndDisplayClassNamesFromScripts", self.derive_and_show_class_names)
	show_timestamps = ProjectSettings.get_setting("Loggie/OutputTimestamps", self.show_timestamps)
	timestamps_use_utc = ProjectSettings.get_setting("Loggie/TimestampsUseUTC", self.timestamps_use_utc)
	box_characters_mode = ProjectSettings.get_setting("Loggie/BoxCharactersMode", self.box_characters_mode)

## Sets the terminal mode in the Loggie settings.
func setTerminalMode(mode : LoggieTools.TerminalMode):
	terminal_mode = mode

## Sets the log level in the Loggie settings.
func setLogLevel(level : LoggieTools.LogLevel):
	log_level = level
