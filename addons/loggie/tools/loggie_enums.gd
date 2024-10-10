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
