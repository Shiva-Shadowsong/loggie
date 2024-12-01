@tool
class_name LoggieEnums extends Node

## Based on which log level is currently set to be used by the Loggie., attempting to log a message that's on
## a higher-than-configured log level will result in nothing happening.
enum LogLevel {
	ERROR, 	## Log level which includes only the logging of Error type messages.
	WARN, 	## Log level which includes the logging of Error and Warning type messages.
	NOTICE, ## Log level which includes the logging of Error, Warning and Notice type messages.
	INFO,	## Log level which includes the logging of Error, Warning, Notice and Info type messages.
	DEBUG	## Log level which includes the logging of Error, Warning, Notice, Info and Debug type messages.
}

## The classification of message types that can be used to distinguish two identical strings in nature
## of their origin. This is different from [enum LogLevel].
enum MsgType {
	STANDARD, ## A message that is considered a standard text that is not special in any way.
	ERROR, ## A message that is considered to be an error message.
	WARNING, ## A message that is considered to be a warning message.
	DEBUG ## A message that is considered to be a message used for debugging.
}

enum TerminalMode {
	PLAIN, ## Prints will be plain text.
	ANSI,  ## Prints will be styled using the ANSI standard. Compatible with Powershell, Win CMD, etc.
	BBCODE ## Prints will be styled using the Godot BBCode rules. Compatible with the Godot console.
}

enum BoxCharactersMode {
	COMPATIBLE, ## Boxes are drawn using characters that compatible with any kind of terminal or text reader.
	PRETTY ## Boxes are drawn using special unicode characters that create a prettier looking box which may not display properly in some terminals or text readers.
}

## Defines a list of possible approaches that can be taken to derive some kind of a class name proxy from a script that doesn't have a 'class_name' clause.
enum NamelessClassExtensionNameProxy {
	NOTHING, ## If there is no class_name, nothing will be displayed.
	SCRIPT_NAME, ## Use the name of the script whose class_name we tried to read. (e.g. "my_script.gd").
	BASE_TYPE, ## Use the name of the base type which the script extends (e.g. 'Node2D', 'Control', etc.)
}

## Defines a list of possible behaviors for the 'show_loggie_specs' setting.
enum ShowLoggieSpecsMode {
	DISABLED, ## Loggie specs won't be shown.
	ESSENTIAL, ## Show only the essentials.
	ADVANCED ## Show all loggie specs.
}

## Defines a list of possible outcomes that can happen when attempting to log a message.
enum LogAttemptResult {
	SUCCESS, ## Message will be logged successfully.
	LOG_LEVEL_INSUFFICIENT, ## Message won't be logged because it was output at a log level higher than what Loggie is currently set to.
	DOMAIN_DISABLED, ## Message won't be logged because it was outputted from a disabled domain.
}
