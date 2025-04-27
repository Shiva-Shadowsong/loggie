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

# ----------------------------------------------- #
#region Project Settings
# ----------------------------------------------- #
## The dictionary which is used to grab the defaults and other values associated with each setting
## relevant to Loggie, particularly important for the default way of loading [LoggieSettings] and
## setting up Godot Project Settings related to Loggie.
const project_settings = {
	"update_check_mode" = {
		"path": "loggie/general/check_for_updates",
		"default_value" : LoggieEnums.UpdateCheckType.CHECK_AND_SHOW_UPDATER_WINDOW,
		"type" : TYPE_INT,
		"hint" : PROPERTY_HINT_ENUM,
		"hint_string" : "Never:0,Only print notice if available:1,Print notice and auto-install:2,Yes and show updater window:3",
		"doc" : "Sets which behavior Loggie should use when checking for updates.",
	},
	"remove_settings_if_plugin_disabled" = {
		"path": "loggie/general/remove_settings_if_plugin_disabled",
		"default_value" : true,
		"type" : TYPE_BOOL,
		"hint" : PROPERTY_HINT_NONE,
		"hint_string" : "",
		"doc" : "Choose whether you want Loggie project settings to be wiped from ProjectSettings if the Loggie plugin is disabled.",
	},
	"msg_format_mode" = {
		"path": "loggie/general/msg_format_mode",
		"default_value" : LoggieEnums.MsgFormatMode.BBCODE,
		"type" : TYPE_INT,
		"hint" : PROPERTY_HINT_ENUM,
		"hint_string" : "Plain:0,ANSI:1,BBCode:2,Markdown:3",
		"doc" : "Choose the format for which loggie should preprocess the output so that it displays correctly on the intended output medium.[br][br]Use BBCode for Godot console.[br]Use ANSI for Powershell, Bash, etc.[br]Use MARKDOWN for Discord.[br]Use PLAIN for log files.",
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
	"default_channels" = {
		"path": "loggie/general/default_channels",
		"default_value" : ["terminal"],
		"type" : TYPE_PACKED_STRING_ARRAY,
		"hint" : PROPERTY_HINT_TYPE_STRING,
		"hint_string" : "",
		"doc" : "The channels messages outputted from Loggie will be sent to by default (if not modified with LoggieMsg.channel method).",
	},
	"skipped_filenames_in_stack_trace" = {
		"path": "loggie/general/skipped_filenames_in_stack_trace",
		"default_value" : ["loggie", "loggie_message"],
		"type" : TYPE_PACKED_STRING_ARRAY,
		"hint" : PROPERTY_HINT_TYPE_STRING,
		"hint_string" : "",
		"doc" : "The file names, which, when appearing in a stack trace, should be omitted from the output.",
	},
	"discord_webhook_url_live" = {
		"path": "loggie/general/discord/live_webhook",
		"default_value" : "",
		"type" : TYPE_STRING,
		"hint" : PROPERTY_HINT_MULTILINE_TEXT,
		"hint_string" : "",
		"doc" : "The endpoint URL for the Discord webhook used when Loggie is running in a production build.",
	},
	"discord_webhook_url_dev" = {
		"path": "loggie/general/discord/dev_webhook",
		"default_value" : "",
		"type" : TYPE_STRING,
		"hint" : PROPERTY_HINT_MULTILINE_TEXT,
		"hint_string" : "",
		"doc" : "The endpoint URL for the Discord webhook used when Loggie is not running in a production build.",
	},
	"slack_webhook_url_live" = {
		"path": "loggie/general/slack/live_webhook",
		"default_value" : "",
		"type" : TYPE_STRING,
		"hint" : PROPERTY_HINT_MULTILINE_TEXT,
		"hint_string" : "",
		"doc" : "The endpoint URL for the Slack webhook used when Loggie is running in a production build.",
	},
	"slack_webhook_url_dev" = {
		"path": "loggie/general/slack/dev_webhook",
		"default_value" : "",
		"type" : TYPE_STRING,
		"hint" : PROPERTY_HINT_MULTILINE_TEXT,
		"hint_string" : "",
		"doc" : "The endpoint URL for the Slack webhook used when Loggie is not running in a production build.",
	},
	"timestamps_use_utc" = {
		"path": "loggie/preprocessing/timestamps_use_utc",
		"default_value" : true,
		"type" : TYPE_BOOL,
		"hint" : PROPERTY_HINT_NONE,
		"hint_string" : "",
		"doc" : "If 'Output Timestamps' is true, should those timestamps use the UTC time. If not, local system time is used instead.",
	},
	"output_errors_to_console" = {
		"path": "loggie/preprocessing/terminal/output_errors_also_to_console",
		"default_value" : true,
		"type" : TYPE_BOOL,
		"hint" : PROPERTY_HINT_NONE,
		"hint_string" : "",
		"doc" : "If true, errors printed by Loggie will also be visible through an additional print in the main output.",
	},
	"output_warnings_to_console" = {
		"path": "loggie/preprocessing/terminal/output_warnings_also_to_console",
		"default_value" : true,
		"type" : TYPE_BOOL,
		"hint" : PROPERTY_HINT_NONE,
		"hint_string" : "",
		"doc" : "If true, warnings printed by Loggie will also be visible through an additional print in the main output.",
	},
	"debug_msgs_print_stack_trace" = {
		"path": "loggie/preprocessing/terminal/debug_msgs_print_stack_trace",
		"default_value" : false,
		"type" : TYPE_BOOL,
		"hint" : PROPERTY_HINT_NONE,
		"hint_string" : "",
		"doc" : "If true, 'debug' level messages outputted by Loggie will also print the stack trace.",
	},
	"nameless_class_name_proxy" = {
		"path": "loggie/preprocessing/nameless_class_name_proxy",
		"default_value" : LoggieEnums.NamelessClassExtensionNameProxy.BASE_TYPE,
		"type" : TYPE_INT,
		"hint" : PROPERTY_HINT_ENUM,
		"hint_string" : "Nothing:0,ScriptName:1,BaseType:2",
		"doc" : "If 'Derive and Display Class Names From Scripts' is enabled, and a script doesn't have a 'class_name', which text should we use as a substitute?",
	},
	"preprocess_flags_terminal_channel" = {
		"path": "loggie/preprocessing/terminal/preprocess_flags",
		"default_value" : LoggieEnums.PreprocessStep.APPEND_TIMESTAMPS | LoggieEnums.PreprocessStep.APPEND_DOMAIN_NAME | LoggieEnums.PreprocessStep.APPEND_CLASS_NAME,
		"type" : TYPE_INT,
		"hint" : PROPERTY_HINT_FLAGS,
		"hint_string" : "Append Timestamp:1,Append Domain Name:2,Append Class Name:4",
		"doc" : "Defines the flags which LoggieMessages sent to the terminal channel will use during preprocessing.",
	},
	"preprocess_flags_discord_channel" = {
		"path": "loggie/preprocessing/discord/preprocess_flags",
		"default_value" : LoggieEnums.PreprocessStep.APPEND_DOMAIN_NAME | LoggieEnums.PreprocessStep.APPEND_CLASS_NAME,
		"type" : TYPE_INT,
		"hint" : PROPERTY_HINT_FLAGS,
		"hint_string" : "Append Timestamp:1,Append Domain Name:2,Append Class Name:4",
		"doc" : "Defines the flags which LoggieMessages sent to the Discord channel will use during preprocessing.",
	},
	"preprocess_flags_slack_channel" = {
		"path": "loggie/preprocessing/slack/preprocess_flags",
		"default_value" : LoggieEnums.PreprocessStep.APPEND_DOMAIN_NAME | LoggieEnums.PreprocessStep.APPEND_CLASS_NAME,
		"type" : TYPE_INT,
		"hint" : PROPERTY_HINT_FLAGS,
		"hint_string" : "Append Timestamp:1,Append Domain Name:2,Append Class Name:4",
		"doc" : "Defines the flags which LoggieMessages sent to the Slack channel will use during preprocessing.",
	},
	"format_timestamp" = {
		"path": "loggie/formats/timestamp",
		"default_value" : "[{day}.{month}.{year} {hour}:{minute}:{second}]",
		"type" : TYPE_STRING,
		"hint" : PROPERTY_HINT_NONE,
		"hint_string" : "",
		"doc" : "The format used for timestamps which are prepended to the message when the appending of timestamps is enabled.",
	},
	"format_stacktrace_entry" = {
		"path": "loggie/formats/stacktrace_entry",
		"default_value" : "{index}: [color=#ff7085]func[/color] [color=#53b1c3][b]{fn_name}[/b]:{line}[/color] [color=slate_gray][i](in {source_path})[/i][/color]",
		"type" : TYPE_STRING,
		"hint" : PROPERTY_HINT_NONE,
		"hint_string" : "",
		"doc" : "The format used for stack trace entries when trace logging is enabled.",
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
	}
}

#endregion
# ----------------------------------------------- #
#region Variables
# ----------------------------------------------- #

## The current behavior Loggie uses to check for updates.
var update_check_mode : LoggieEnums.UpdateCheckType = LoggieEnums.UpdateCheckType.CHECK_AND_SHOW_UPDATER_WINDOW

## The current Message Format Mode of Loggie.
## Message Format Mode determines whether BBCode, ANSI or some other type of
## formatting is used to convey text effects, such as bold, italic, colors, etc.
## [br][br]BBCode is compatible with the Godot console.
## [br]ANSI is compatible with consoles like Powershell and Windows CMD.
## [br]PLAIN is used to strip any effects and use plain text instead, which is good for saving raw logs into log files.
var msg_format_mode : LoggieEnums.MsgFormatMode = LoggieEnums.MsgFormatMode.BBCODE

## The current log level of Loggie.
## It determines which types of messages are allowed to be logged.
## Set this using [method setLogLevel].
var log_level : LoggieEnums.LogLevel = LoggieEnums.LogLevel.INFO

## Whether or not Loggie should log the loggie specs on ready.
var show_loggie_specs : LoggieEnums.ShowLoggieSpecsMode = LoggieEnums.ShowLoggieSpecsMode.ESSENTIAL

## Whether or not Loggie should log the system specs on ready.
var show_system_specs : bool = true

## Whether to, in addition to logging errors with [method push_error], 
## Loggie should also print the error as a message in the standard output.
var print_errors_to_console : bool = true

## Whether to, in addition to logging errors with [method push_warning], 
## Loggie should also print the error as a message in the standard output.
var print_warnings_to_console : bool = true

## Defines which text will be used as a substitute for the 'class_name' of scripts that do not have a 'class_name'.
## Relevant only during the [member LoggieEnums.PreprocessStep.APPEND_CLASS_NAME] step of preprocessing.
var nameless_class_name_proxy : LoggieEnums.NamelessClassExtensionNameProxy

## Whether the outputted timestamps use UTC or local machine time.
var timestamps_use_utc : bool = true

## If true, when outputting Debug level messages, the stack trace will also be appended.
var debug_msgs_print_stack_trace : bool = false

## Whether Loggie should enforce optimal values for certain settings when in a Release/Production build.
## [br]If true, Loggie will enforce:
## [br]  * [member msg_format_mode] to [member LoggieEnums.MsgFormatMode.PLAIN]
## [br]  * [member box_characters_mode] to [member LoggieEnums.BoxCharactersMode.COMPATIBLE]
var enforce_optimal_settings_in_release_build : bool = true

## Endpoint URL for the Discord webhook (used in dev environment)
## [br][b]NEVER[/b] distribute your webhook in your project's repository, source code, or built game, where it can be accessed by other people.
## This is meant to be used only in controlled circumstances.
var discord_webhook_url_dev : String = "" 

## Endpoint URL for the Discord webhook (used in production/release environment)
## [br][b]NEVER[/b] distribute your webhook in your project's repository, source code, or built game, where it can be accessed by other people.
## This is meant to be used only in controlled circumstances.
var discord_webhook_url_live : String = "" 

## Endpoint URL for the Slack webhook (used in dev environment)
## [br][b]NEVER[/b] distribute your webhook in your project's repository, source code, or built game, where it can be accessed by other people.
## This is meant to be used only in controlled circumstances.
var slack_webhook_url_dev : String = "" 

## Endpoint URL for the Slack webhook (used in production/release environment)
## [br][b]NEVER[/b] distribute your webhook in your project's repository, source code, or built game, where it can be accessed by other people.
## This is meant to be used only in controlled circumstances.
var slack_webhook_url_live : String = "" 

## Defines the flags which LoggieMessages sent to the terminal channel will use during preprocessing.
var preprocess_flags_terminal_channel = LoggieEnums.PreprocessStep.APPEND_TIMESTAMPS | LoggieEnums.PreprocessStep.APPEND_DOMAIN_NAME | LoggieEnums.PreprocessStep.APPEND_CLASS_NAME

## Defines the flags which LoggieMessages sent to the Discord channel output will use during preprocessing.
var preprocess_flags_discord_channel = LoggieEnums.PreprocessStep.APPEND_DOMAIN_NAME | LoggieEnums.PreprocessStep.APPEND_CLASS_NAME

## Defines the flags which LoggieMessages sent to the Slack channel output will use during preprocessing.
var preprocess_flags_slack_channel = LoggieEnums.PreprocessStep.APPEND_DOMAIN_NAME | LoggieEnums.PreprocessStep.APPEND_CLASS_NAME

## The list of channels a message outputted from Loggie should be sent to by default.
var default_channels : PackedStringArray = ["terminal"]

## The list of file names, which, when appearing in a stack trace, should be omitted from the output..
var skipped_filenames_in_stack_trace : PackedStringArray = ["loggie", "loggie_message"]

#endregion
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

## The format used for timestamps when they are prepended to the output.[br]
## The variables [param {day}], [param {month}], [param {year}], [param {hour}], [param {minute}], [param {second}], [param {weekday}], and [param {dst}] are supported.
## You can customize this in your ProjectSettings, or custom_settings.gd (if using it).[br]
var format_timestamp = "[{day}.{month}.{year} {hour}:{minute}:{second}]"

## The format used for each entry in a stack trace that is obtained through [method Loggie.stack].
## The variables [param {fn_name}], [param {index}], [param {source_path}], [param {line}] are supported.
## You can customize this in your ProjectSettings, or custom_settings.gd (if using it).[br]
var format_stacktrace_entry = "{index}: [color=#ff7085]func[/color] [color=#53b1c3][b]{fn_name}[/b]:{line}[/color] [color=slate_gray][i](in {source_path})[/i][/color]"

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

## A [Callable] function that takes 1 parameter [param something] (Variant),
## and returns a [String] which represents the given [param something] in text.
## By default, Loggie sets this to `LoggieTools.convert_to_string` when initialized.
## [br][br]
## You can, however, override that by changing this value to a valid replacement [Callable], 
## after Loggie has initialized.
var custom_string_converter : Callable

## Loads the initial (default) values for all of the LoggieSettings variables.
## (By default, loads them from ProjectSettings (if any modifications there exist), 
## or looks in [LoggieEditorPlugin..project_settings] for default values).
## [br][br]Extend this class and override this function to write your own logic for 
## how loggie should obtain these settings if you have a need for a different approach.
func load():
	update_check_mode = ProjectSettings.get_setting(project_settings.update_check_mode.path, project_settings.update_check_mode.default_value)
	msg_format_mode = ProjectSettings.get_setting(project_settings.msg_format_mode.path, project_settings.msg_format_mode.default_value)
	log_level = ProjectSettings.get_setting(project_settings.log_level.path, project_settings.log_level.default_value)
	show_loggie_specs = ProjectSettings.get_setting(project_settings.show_loggie_specs.path, project_settings.show_loggie_specs.default_value)
	show_system_specs = ProjectSettings.get_setting(project_settings.show_system_specs.path, project_settings.show_system_specs.default_value)
	timestamps_use_utc = ProjectSettings.get_setting(project_settings.timestamps_use_utc.path, project_settings.timestamps_use_utc.default_value)
	enforce_optimal_settings_in_release_build = ProjectSettings.get_setting(project_settings.enforce_optimal_settings_in_release_build.path, project_settings.enforce_optimal_settings_in_release_build.default_value)
	default_channels = ProjectSettings.get_setting(project_settings.default_channels.path, project_settings.default_channels.default_value)
	skipped_filenames_in_stack_trace = ProjectSettings.get_setting(project_settings.skipped_filenames_in_stack_trace.path, project_settings.skipped_filenames_in_stack_trace.default_value)

	print_errors_to_console = ProjectSettings.get_setting(project_settings.output_errors_to_console.path, project_settings.output_errors_to_console.default_value)
	print_warnings_to_console = ProjectSettings.get_setting(project_settings.output_warnings_to_console.path, project_settings.output_warnings_to_console.default_value)
	debug_msgs_print_stack_trace = ProjectSettings.get_setting(project_settings.debug_msgs_print_stack_trace.path, project_settings.debug_msgs_print_stack_trace.default_value)

	nameless_class_name_proxy = ProjectSettings.get_setting(project_settings.nameless_class_name_proxy.path, project_settings.nameless_class_name_proxy.default_value)
	box_characters_mode = ProjectSettings.get_setting(project_settings.box_characters_mode.path, project_settings.box_characters_mode.default_value)

	format_timestamp = ProjectSettings.get_setting(project_settings.format_timestamp.path, project_settings.format_timestamp.default_value)
	format_stacktrace_entry = ProjectSettings.get_setting(project_settings.format_stacktrace_entry.path, project_settings.format_stacktrace_entry.default_value)
	format_info_msg = ProjectSettings.get_setting(project_settings.format_info_msg.path, project_settings.format_info_msg.default_value)
	format_notice_msg = ProjectSettings.get_setting(project_settings.format_notice_msg.path, project_settings.format_notice_msg.default_value)
	format_warning_msg = ProjectSettings.get_setting(project_settings.format_warning_msg.path, project_settings.format_warning_msg.default_value)
	format_error_msg = ProjectSettings.get_setting(project_settings.format_error_msg.path, project_settings.format_error_msg.default_value)
	format_debug_msg = ProjectSettings.get_setting(project_settings.format_debug_msg.path, project_settings.format_debug_msg.default_value)
	h_separator_symbol = ProjectSettings.get_setting(project_settings.h_separator_symbol.path, project_settings.h_separator_symbol.default_value)
	
	discord_webhook_url_live = ProjectSettings.get_setting(project_settings.discord_webhook_url_live.path, project_settings.discord_webhook_url_live.default_value)
	discord_webhook_url_dev = ProjectSettings.get_setting(project_settings.discord_webhook_url_dev.path, project_settings.discord_webhook_url_dev.default_value)
	preprocess_flags_discord_channel = ProjectSettings.get_setting(project_settings.preprocess_flags_discord_channel.path, project_settings.preprocess_flags_discord_channel.default_value)
	slack_webhook_url_live = ProjectSettings.get_setting(project_settings.slack_webhook_url_live.path, project_settings.slack_webhook_url_live.default_value)
	slack_webhook_url_dev = ProjectSettings.get_setting(project_settings.slack_webhook_url_dev.path, project_settings.slack_webhook_url_dev.default_value)
	preprocess_flags_slack_channel = ProjectSettings.get_setting(project_settings.preprocess_flags_slack_channel.path, project_settings.preprocess_flags_slack_channel.default_value)
	preprocess_flags_terminal_channel = ProjectSettings.get_setting(project_settings.preprocess_flags_terminal_channel.path, project_settings.preprocess_flags_terminal_channel.default_value)

## Returns a dictionary where the indices are names of relevant variables in the LoggieSettings class,
## and the values are their current values.
func to_dict() -> Dictionary:
	var dict = {}
	var included = [
		"preprocess_flags_discord_channel", "preprocess_flags_slack_channel", "preprocess_flags_terminal_channel",
		"default_channels", "skipped_filenames_in_stack_trace", "msg_format_mode", "log_level", "show_loggie_specs", "show_system_specs", "enforce_optimal_settings_in_release_build",
		"print_errors_to_console", "print_warnings_to_console",
		"debug_msgs_print_stack_trace", "nameless_class_name_proxy",
		"timestamps_use_utc", "format_header", "format_domain_prefix", "format_error_msg",
		"format_warning_msg", "format_notice_msg", "format_info_msg", "format_debug_msg", "format_timestamp",
		"h_separator_symbol", "box_characters_mode", "box_symbols_compatible", "box_symbols_pretty",
	]
	
	for var_name in included:
		dict[var_name] = get(var_name)
	return dict
