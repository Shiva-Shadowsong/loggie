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

enum MsgFormatMode {
	PLAIN, ## Prints will be plain text.
	ANSI,  ## Prints will be styled using the ANSI standard. Compatible with Powershell, Win CMD, etc.
	BBCODE, ## Prints will be styled using the Godot BBCode rules. Compatible with the Godot console.
	MARKDOWN, ## Prints will be styled using the Markdown standard. Compatible with most Markdown readers.
}

## Classifies various steps that can happen during preprocessing.
enum PreprocessStep {
	## A timestamp will be added to the message.
	APPEND_TIMESTAMPS = 1 << 0, 
	
	## The name of the domain from which the message is coming will be added to the message.
	APPEND_DOMAIN_NAME = 1 << 1, 

	## Whether Loggie should use the scripts from which it is being called to 
	## figure out a class name for the class that called a loggie function,
	## and append it to the outputted message.
	## This only works in debug builds because it uses [method @GDScript.get_stack]. 
	## See that method's documentation to see why that can't be used in release builds.
	APPEND_CLASS_NAME = 1 << 2,
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
	INVALID_CHANNEL, ## Message won't be logged because the channel which was supposed to send it doesn't exist.
}

## Defines a list of possible ways to configure Loggie to check for updates.
enum UpdateCheckType {
	DONT_CHECK, ## If the user doesn't want Loggie to check for updates at all.
	CHECK_AND_SHOW_MSG, ## If the user wants Loggie to check for updates, and display info in a terminal message.
	CHECK_DOWNLOAD_AND_SHOW_MSG, ## If the user wants Loggie to check for updates, download the update, and display info in a terminal message.
	CHECK_AND_SHOW_UPDATER_WINDOW, ## If the user wants Loggie to check for updats, and display the updater window.
}
