@tool

## LoggieMsg represents a mutable object that holds an array of strings ([member content]) [i](referred to as 'content segments')[/i], and
## a bunch of helper methods that make it easy to manipulate these segments and chain together additions and changes to them.
## [br][br]For example:
## [codeblock]
### Prints: "Hello world!" at the INFO debug level.
##var msg = LoggieMsg.new("Hello world").color(Color.RED).suffix("!").info() 
##[/codeblock]
## [br] You can also use [method Loggie.msg] to quickly construct a message.
## [br] Example of usage:
## [codeblock]Loggie.msg("Hello world").color(Color("#ffffff")).suffix("!").info()[/codeblock]
class_name LoggieMsg extends RefCounted

## The full content of this message. By calling various helper methods in this class, this content is further altered.
## The content is an array of strings which represents segments of the message which are ultimately appended together 
## to form the final message. You can start a new segment by calling [method msg] on this class.
## You can then output the whole message with methods like [method info], [method debug], etc.
var content : Array = [""]

## The segment of [member content] that is currently being edited.
var current_segment_index : int = 0

## The (key string) domain this message belongs to.
## "" is the default domain which is always enabled.
## If this message attempts to be outputted, but belongs to a disabled domain, it will not be outputted.
## You can change which domains are enabled in Loggie at any time with [Loggie.set_domain_enabled].
## This is useful for creating blocks of debugging output that you can simply turn off/on with a boolean when you actually need them.
var domain_name : String = ""

## Stores a reference to the logger that generated this message, from which we need to read settings and other data.
## This variable should be set with [method use_logger] before an attempt is made to log this message out.
var _logger : Variant

## Stores an array of IDs of all channels this message should be sent to when being outputted.
var used_channels : Array = ["terminal"]

## Whether this message should be preprocessed and modified during [method output].
var preprocess : bool = true

## Usually, the [LoggieMsgChannel] this message gets outputted on sets the preprocessing steps this message should use.
## But sometimes we may want to use a specific set of preprocessing steps on this message,
## overriding the channel's set of rules.
## In that case, set this variable to the value of the [LoggieEnums.PreprocessStep] flags you want this message to use with
## [method preprocess].
var custom_preprocess_flags : int = -1

## Stores the string which was obtained the last time the [method get_preprocessed] was called on this message.
## You need to call it at least once for this to have any results.
var last_preprocess_result : String = ""

## Stores the integer value of a [enum LoggieEnums.LogLevel], matching the log level
## this message was most recently outputted at. If value is `-1`, the message was never
## outputted yet.
var last_outputted_at_log_level : int = -1

## Whether this message should append the stack trace during preprocessing.
var appends_stack : bool = false

## Controls whether the [enum LoggieEnums.MsgType] of this message, during [method output], 
## will be decided dynamically, based on the [enum LoggieEnums.LogLevel] the message is being output at.
## If disabled, the [member strict_type] will be used instead.
var dynamic_type : bool = true

## The [LoggieEnums.MsgType] this message will be considered typed as, if [member dynamic_type] is set
## to [param false].
var strict_type : LoggieEnums.MsgType = LoggieEnums.MsgType.INFO

## The environment in which this message should be outputted based on the context the output is being requested from.
## (e.g. only in-engine (during tool scripts), or only ingame, or both).
var environment_mode : LoggieEnums.MsgEnvironment = LoggieEnums.MsgEnvironment.BOTH

## If set to true, the [signal Loggie.log_attempted] signal will not be emitted when this message attempts to be outputted.
var dont_emit_log_attempted_signal : bool = false

func _init(message = "", arg1 = null, arg2 = null, arg3 = null, arg4 = null, arg5 = null) -> void:
	var args = [message, arg1, arg2, arg3, arg4, arg5]
	self.content[0] = LoggieTools.concatenate_args(args)
	self.set_meta("initial_args", args)

## Returns a reference to the logger object that created this message.
func get_logger() -> Variant:
	return self._logger

## Sets this message to use the given [param logger] as the logger from which it will be reading
## settings. The given logger should be of class [Loggie] or an extension of it.
func use_logger(logger_to_use : Variant) -> LoggieMsg:
	self._logger = logger_to_use
	self.used_channels = self._logger.settings.default_channels
	
	# Now that a logger is connected, we can re-format the first segment
	# using that Logger's converter function if it has a custom one defined.
	if self.has_meta("initial_args"):
		var initial_args = self.get_meta("initial_args")
		if initial_args is Array:
			var converter_fn = self._logger.settings.custom_string_converter if is_instance_valid(self._logger) and is_instance_valid(self._logger.settings) else null
			if converter_fn != LoggieTools.convert_to_string:
				self.content[0] = LoggieTools.concatenate_args(initial_args, converter_fn)
		self.remove_meta("initial_args") # Clean up.

	return self

## Sets the list of channels this message should be sent to when outputted.
## [param channels] should either be provided as a single channel ID (String), or
## as an array of channel IDs (Array of strings).
func channel(channels : Variant) -> LoggieMsg:
	if typeof(channels) != TYPE_ARRAY and typeof(channels) != TYPE_PACKED_STRING_ARRAY:
		channels = [str(channels)]
	self.used_channels = channels
	return self

## Returns a processed version of the content of this message, which has modifications applied to
## it based on the requested [param type] and other settings defined by the provided preprocess [param flags].
## Available preprocess flags are found in [enum LoggieEnums.PreprocessStep].
func get_preprocessed(flags : int, _level : LoggieEnums.LogLevel, type : LoggieEnums.MsgType) -> String:
	var loggie = get_logger()
	var message = self.string()

	match type:
		LoggieEnums.MsgType.ERROR:
			message = loggie.settings.format_error_msg.format({"msg": message})
		LoggieEnums.MsgType.WARN:
			message = loggie.settings.format_warning_msg.format({"msg": message})
		LoggieEnums.MsgType.NOTICE:
			message = loggie.settings.format_notice_msg.format({"msg": message})
		LoggieEnums.MsgType.INFO:
			message = loggie.settings.format_info_msg.format({"msg": message})
		LoggieEnums.MsgType.DEBUG:
			message = loggie.settings.format_debug_msg.format({"msg": message})

	if (flags & LoggieEnums.PreprocessStep.APPEND_DOMAIN_NAME != 0) and !self.domain_name.is_empty():
		message = _apply_format_domain(message)

	if (flags & LoggieEnums.PreprocessStep.APPEND_CLASS_NAME != 0) and OS.has_feature("debug"):
		message = _apply_format_class_name(message)

	if (flags & LoggieEnums.PreprocessStep.APPEND_TIMESTAMPS != 0):
		message = _apply_format_timestamp(message)

	if self.appends_stack or (loggie.settings.debug_msgs_print_stack_trace and type == LoggieEnums.MsgType.DEBUG):
		message = _apply_format_stack(message)

	return message

## Outputs the given string [param message] at the given output [param level] to the standard output using either [method print_rich] or [method print].
## The domain from which the message is considered to be coming can be provided via [param target_domain].
## The message type can be provided via [param msg_type], but it will be ignored if [member dynamic_type] is false,
## in which case, the [member strict_type] will be used.
## It also does a number of changes to the given [param msg] based on various Loggie settings.
## Designed to be called internally. You should consider using [method info], [method error], [method warn], [method notice], [method debug] instead.
func output(level : LoggieEnums.LogLevel, msg_type : LoggieEnums.MsgType = LoggieEnums.MsgType.INFO) -> void:
	var loggie = get_logger()
	var message = self.string()
	var target_domain = self.domain_name
	var target_channels = self.used_channels
	
	if loggie == null:
		push_error("Attempt to log output with an invalid _logger. Make sure to call LoggieMsg.use_logger to set the appropriate logger before working with the message.")
		return
		
	if loggie.settings == null:
		push_error("Attempt to use a _logger with invalid settings to print: {msg}".format({"msg": message}))
		return

	# We don't output the message if the settings dictate that messages of that level shouldn't be outputted.
	if level > loggie.settings.log_level:
		_emit_log_attempted_signal(LoggieEnums.LogAttemptResult.LOG_LEVEL_INSUFFICIENT)
		return

	# We don't output the message if the domain from which it comes is not enabled.
	if not loggie.is_domain_enabled(target_domain):
		_emit_log_attempted_signal(LoggieEnums.LogAttemptResult.DOMAIN_DISABLED)
		return

	# We don't output the message if the environment the output is being requested from is not compatible with 
	# the environment this message is configured to be outputted in.
	match environment_mode:
		LoggieEnums.MsgEnvironment.ENGINE:
			if not Engine.is_editor_hint():
				_emit_log_attempted_signal(LoggieEnums.LogAttemptResult.WRONG_ENVIRONMENT)
				return
		LoggieEnums.MsgEnvironment.RUNTIME:
			if Engine.is_editor_hint():
				_emit_log_attempted_signal(LoggieEnums.LogAttemptResult.WRONG_ENVIRONMENT)
				return

	# Enforce the strict type of this message if it is configured not to allow dynamic type.
	if !dynamic_type:
		msg_type = strict_type

	# Send the message on all configured channels.
	var custom_target_channels = loggie.get_domain_custom_target_channels(target_domain)
	if custom_target_channels.size() > 0:
		target_channels = custom_target_channels

	for channel_id : String in target_channels:
		var channel : LoggieMsgChannel = loggie.get_channel(channel_id)

		if channel == null:
			_emit_log_attempted_signal(LoggieEnums.LogAttemptResult.INVALID_CHANNEL)
			continue

		# Preprocessing Stage:
		#   Apply full preprocessing only if explicitly enabled.
		#   Otherwise, simply concatenate together all the [member content].
		if self.preprocess:
			var flags = self.custom_preprocess_flags if self.custom_preprocess_flags != -1 else channel.preprocess_flags
			self.last_preprocess_result = get_preprocessed(flags, level, msg_type)
		else:
			self.last_preprocess_result = self.string()

		self.last_outputted_at_log_level = int(level)
		channel.send(self, msg_type)
		
	# Emit signal deferred so if this is called from a thread, it doesn't cry about it.
	_emit_log_attempted_signal(LoggieEnums.LogAttemptResult.SUCCESS, true)

## Outputs this message from Loggie as an Error type message.
## The [Loggie.settings.log_level] must be equal to or higher to the ERROR level for this to work.
func error() -> LoggieMsg:
	output(LoggieEnums.LogLevel.ERROR, LoggieEnums.MsgType.ERROR)
	return self

## Outputs this message from Loggie as an Warning type message.
## The [Loggie.settings.log_level] must be equal to or higher to the WARN level for this to work.
func warn() -> LoggieMsg:
	output(LoggieEnums.LogLevel.WARN, LoggieEnums.MsgType.WARN)
	return self

## Outputs this message from Loggie as an Notice type message.
## The [Loggie.settings.log_level] must be equal to or higher to the NOTICE level for this to work.
func notice() -> LoggieMsg:
	output(LoggieEnums.LogLevel.NOTICE, LoggieEnums.MsgType.NOTICE)
	return self

## Outputs this message from Loggie as an Info type message.
## The [Loggie.settings.log_level] must be equal to or higher to the INFO level for this to work.
func info() -> LoggieMsg:
	output(LoggieEnums.LogLevel.INFO, LoggieEnums.MsgType.INFO)
	return self

## Outputs this message from Loggie as a Debug type message.
## The [Loggie.settings.log_level] must be equal to or higher to the DEBUG level for this to work.
func debug() -> LoggieMsg:
	output(LoggieEnums.LogLevel.DEBUG, LoggieEnums.MsgType.DEBUG)
	return self

## Returns the string content of this message.
## If [param segment] is provided, it should be an integer indicating which segment of the message to return.
## If its value is -1, all segments are concatenated together and returned.
func string(segment : int = -1) -> String:
	if segment == -1:
		return "".join(self.content)
	else:
		if segment < self.content.size():
			return self.content[segment]
		else:
			push_error("Attempt to access a non-existent segment of a LoggieMsg. Make sure to use a valid segment index.")
			return ""

## Converts the current content of this message to an ANSI compatible form.
func to_ANSI() -> LoggieMsg:
	var new_content : Array = []
	for segment in self.content:
		new_content.append(LoggieTools.rich_to_ANSI(segment))
	self.content = new_content
	return self

## Strips all the BBCode in the current content of this message.
func strip_BBCode() -> LoggieMsg:
	var new_content : Array = []
	for segment in self.content:
		new_content.append(LoggieTools.remove_BBCode(segment))
	self.content = new_content
	return self

## Wraps the content of the current segment of this message in the given color.
## The [param color] can be provided as a [Color], a recognized Godot color name (String, e.g. "red"), or a color hex code (String, e.g. "#ff0000").
func color(_color : Variant) -> LoggieMsg:
	if _color is Color:
		_color = _color.to_html()
	
	self.content[current_segment_index] = "[color={colorstr}]{msg}[/color]".format({
		"colorstr": _color, 
		"msg": self.content[current_segment_index]
	})

	return self

## Stylizes the current segment of this message to be bold.
func bold() -> LoggieMsg:
	self.content[current_segment_index] = "[b]{msg}[/b]".format({"msg": self.content[current_segment_index]})
	return self

## Stylizes the current segment of this message to be italic.
func italic() -> LoggieMsg:
	self.content[current_segment_index] = "[i]{msg}[/i]".format({"msg": self.content[current_segment_index]})
	return self

## Makes the current segment of this message a hyperlink to the given [param url].
## Optionally, you can provide a [param color], as the same type of parameter that [method color] uses,
## to colorize the link. This is a shortcut for additionally calling [method color] on the link.
## [br][br]If the link doesn't work when rendered inside of a [RichTextLabel], you may need to connect to the [signal RichTextLabel.meta_clicked] signal,
## and handle the opening of the link there. Read the docs of that signal for more info.
## [br][br][WARNING]: Appending URLs to messages is potentially dangerous. 
## Please read this article for more info: https://docs.godotengine.org/en/latest/tutorials/ui/bbcode_in_richtextlabel.html#handling-user-input-safely
func link(url : String, _color : Variant = null) -> LoggieMsg:
	self.content[current_segment_index] = "[url={url}]{msg}[/url]".format({"url": url, "msg": self.content[current_segment_index]})
	if _color:
		self.color(_color)
	return self

## Stylizes the current segment of this message as a header.
func header() -> LoggieMsg:
	var loggie = get_logger()
	self.content[current_segment_index] = loggie.settings.format_header.format({"msg": self.content[current_segment_index]})
	return self

## Sets whether this message should append the stack trace during preprocessing.
## If used in a different thread, it doesn't work, because it relies on [method get_stack] and
## that method doesn't work within threads.
func stack(enabled : bool = true) -> LoggieMsg:
	self.appends_stack = enabled
	return self

## Constructs a decorative box with the given horizontal padding around the current segment
## of this message. Messages containing a box are not going to be preprocessed, so they are best
## used only as a special header or decoration.
func box(h_padding : int = 4) -> LoggieMsg:
	var loggie = get_logger()
	var stripped_content = LoggieTools.remove_BBCode(self.content[current_segment_index]).strip_edges(true, true)
	var content_length = stripped_content.length()
	var h_fill_length = content_length + (h_padding * 2)
	var box_character_source = loggie.settings.box_symbols_compatible if loggie.settings.box_characters_mode == LoggieEnums.BoxCharactersMode.COMPATIBLE else loggie.settings.box_symbols_pretty

	var top_row_design = "{top_left_corner}{h_fill}{top_right_corner}".format({
		"top_left_corner" : box_character_source.top_left,
		"h_fill" : box_character_source.h_line.repeat(h_fill_length),
		"top_right_corner" : box_character_source.top_right
	})

	var middle_row_design = "{vert_line}{padding}{content}{space_fill}{padding}{vert_line}".format({
		"vert_line" : box_character_source.v_line,
		"content" : self.content[current_segment_index],
		"padding" : " ".repeat(h_padding),
		"space_fill" : " ".repeat(h_fill_length - stripped_content.length() - h_padding*2)
	})
	
	var bottom_row_design = "{bottom_left_corner}{h_fill}{bottom_right_corner}".format({
		"bottom_left_corner" : box_character_source.bottom_left,
		"h_fill" : box_character_source.h_line.repeat(h_fill_length),
		"bottom_right_corner" : box_character_source.bottom_right
	})
	
	self.content[current_segment_index] = "{top_row}\n{middle_row}\n{bottom_row}\n".format({
		"top_row" : top_row_design,
		"middle_row" : middle_row_design,
		"bottom_row" : bottom_row_design
	})
	
	self.preprocessed(false)
	return self
	
## Appends additional content to this message at the end of the current content and its stylings.
## This does not create a new message segment, just appends to the current one.
func add(message : Variant = null, arg1 : Variant = null, arg2 : Variant = null, arg3 : Variant = null, arg4 : Variant = null, arg5 : Variant = null) -> LoggieMsg:
	var converter_fn = self._logger.settings.custom_string_converter if is_instance_valid(self._logger) and is_instance_valid(self._logger.settings) else null
	self.content[current_segment_index] = self.content[current_segment_index] + LoggieTools.concatenate_args([message, arg1, arg2, arg3, arg4, arg5], converter_fn)
	return self

## Adds a specified amount of newlines to the end of the current segment of this message.
func nl(amount : int = 1) -> LoggieMsg:
	self.content[current_segment_index] += "\n".repeat(amount)
	return self

## Adds a specified amount of spaces to the end of the current segment of this message.
func space(amount : int = 1) -> LoggieMsg:
	self.content[current_segment_index] += " ".repeat(amount)
	return self

## Adds a specified amount of tabs to the end of the current segment of this message.
func tab(amount : int = 1) -> LoggieMsg:
	self.content[current_segment_index] += "\t".repeat(amount)
	return self

## Sets this message to belong to the domain with the given name.
## If it attempts to be outputted, but the domain is disabled, it won't be outputted.
func domain(_domain_name : String) -> LoggieMsg:
	self.domain_name = _domain_name
	return self

## Prepends the given prefix string to the start of the message (first segment) with the provided separator.
func prefix(str_prefix : String, separator : String = "") -> LoggieMsg:
	self.content[0] = "{prefix}{separator}{content}".format({
		"prefix" : str_prefix,
		"separator" : separator,
		"content" : self.content[0]
	})
	return self

## Appends the given suffix string to the end of the message (last segment) with the provided separator.
func suffix(str_suffix : String, separator : String = "") -> LoggieMsg:
	self.content[self.content.size() - 1] = "{content}{separator}{suffix}".format({
		"suffix" : str_suffix,
		"separator" : separator,
		"content" : self.content[self.content.size() - 1]
	})
	return self

## Appends a horizontal separator with the given length to the current segment of this message.
## If [param alternative_symbol] is provided, it should be a String, and it will be used as the symbol for the separator instead of the default one.
func hseparator(size : int = 16, alternative_symbol : Variant = null) -> LoggieMsg:
	var loggie = get_logger()
	var symbol = loggie.settings.h_separator_symbol if alternative_symbol == null else str(alternative_symbol)
	self.content[current_segment_index] = self.content[current_segment_index] + (symbol.repeat(size))
	return self

## Ends the current segment of the message and starts a new one.
func endseg() -> LoggieMsg:
	self.content.push_back("")
	self.current_segment_index = self.content.size() - 1
	return self

## Sets the environment in which this message should be outputted based on the context the output is being requested from.
## (e.g. only in-engine (during tool scripts), or only ingame, or both).
func env(mode : LoggieEnums.MsgEnvironment) -> LoggieMsg:
	self.environment_mode = mode
	return self

## Creates a new segment in this message and sets its content to the given message.
## Acts as a shortcut for calling [method endseg] + [method add].
func msg(message = "", arg1 = null, arg2 = null, arg3 = null, arg4 = null, arg5 = null) -> LoggieMsg:
	self.endseg()
	var converter_fn = self._logger.settings.custom_string_converter if is_instance_valid(self._logger) and is_instance_valid(self._logger.settings) else null
	self.content[current_segment_index] = LoggieTools.concatenate_args([message, arg1, arg2, arg3, arg4, arg5], converter_fn)
	return self

## Sets whether this message should be preprocessed and potentially modified with prefixes and suffixes during [method output].
## If turned off, while outputting this message, Loggie will skip the steps where it appends the messaage domain, class name, timestamp, etc.
## Whether preprocess is set to true doesn't affect the final conversion from RICH to ANSI or PLAIN, which always happens 
## under some circumstances that are based on other settings.
func preprocessed(shouldPreprocess : bool) -> LoggieMsg:
	self.preprocess = shouldPreprocess
	return self

## Sets this message's [LoggieEnums.MsgType] to be strictly the provided value,
## instead of dynamically decided by the log level at which it is being outputted.
## [br][param loggie_enums_msgtype_key_or_value] should either be provided as a direct value of the enum,
## (e.g. [enum LoggieEnum.MsgType.INFO]) or as a string matching one of the keys in that enum (e.g.
## `"info"` or `"INFO"`, case-insensitive).
func type(loggie_enums_msgtype_key_or_value : Variant) -> LoggieMsg:
	var isValid = false
	var _type : LoggieEnums.MsgType

	if loggie_enums_msgtype_key_or_value is LoggieEnums.MsgType:
		_type = loggie_enums_msgtype_key_or_value
		isValid = true
	elif loggie_enums_msgtype_key_or_value is String:
		var uppercase_key = loggie_enums_msgtype_key_or_value.to_upper()
		if LoggieEnums.MsgType.keys().has(uppercase_key):
			_type = LoggieEnums.MsgType[uppercase_key]
			isValid = true 
	
	if isValid:
		dynamic_type = false
		strict_type = _type
	else:
		push_error("Attempt to set LoggieMsg type to {value} - could not be converted to a proper [LoggieEnums.MsgType]. Either provide a [LoggieEnums.MsgType], or a string that matches a key in that enum (case-insensitive).".format({"value": str(loggie_enums_msgtype_key_or_value)}))

	return self

## If [param enabled], the [signal Loggie.log_attempted] signal will not be emitted when this message attempts to be outputted.
func no_signal(enabled : bool = true) -> LoggieMsg:
	dont_emit_log_attempted_signal = enabled
	return self

## Applies the [LoggiePreset] with the given [param id] to this message.
## [br]If [param apply_only_to_current_segment] is [param true], the styles from the preset will only be
## applied to the current content segment of this message. Otherwise, the entire content of this message
## will be collapsed into a single segment, and the styles will be applied to that.
func preset(id : String, apply_only_to_current_segment : bool = false) -> LoggieMsg:
	var loggie = get_logger()
	var preset_to_use : LoggiePreset = loggie.preset(id)
	if preset_to_use:
		preset_to_use.apply_to(self, apply_only_to_current_segment)
	else:
		push_error("Attempt to obtain LoggiePreset with ID {id} returned null. Something went terribly wrong, as this should usually be impossible.")
	return self

## Internal method. Emits the [signal Loggie.log_attempted] signal (unless that feature is disabled).
## Used during [method output]. If [param call_deferred] is true, the string of the message's content will
## be prepared immediately, but the emission of the signal will be deferred.
func _emit_log_attempted_signal(result : LoggieEnums.LogAttemptResult, call_deferred : bool = false) -> void:
	if dont_emit_log_attempted_signal:
		return

	var loggie = get_logger()
	var string_content = self.string()

	if call_deferred:
		loggie.call_deferred("emit_signal", "log_attempted", self, string_content, result)
	else:
		loggie.log_attempted.emit(self, string_content, result)

## Adds this message's configured domain to the start of the given [param message] and returns the modifier version of it.
func _apply_format_domain(message : String) -> String:
	var loggie = get_logger()
	message = loggie.settings.format_domain_prefix.format({"domain" : self.domain_name, "msg" : message})
	return message

## Adds a formatted class name to the given [param message] and returns the modified version of it.
func _apply_format_class_name(message : String) -> String:
	var loggie = get_logger()
	var stack_frame : Dictionary = LoggieTools.get_current_stack_frame_data()
	var _class_name : String

	var scriptPath = stack_frame.source
	if loggie.class_names.has(scriptPath):
		_class_name = loggie.class_names[scriptPath]
	else:
		_class_name = LoggieTools.get_class_name_from_script(scriptPath, loggie.settings.nameless_class_name_proxy)
		loggie.class_names[scriptPath] = _class_name
	
	if _class_name != "":
		message = "[b]({class_name})[/b] {msg}".format({
			"class_name" : _class_name,
			"msg" : message
		})
	return message

## Adds a formatted timestamp to the given [param message] and returns the modified version of it.
func _apply_format_timestamp(message : String) -> String:
	var loggie = get_logger()
	var format_dict : Dictionary = Time.get_datetime_dict_from_system(loggie.settings.timestamps_use_utc)
	for field in ["month", "day", "hour", "minute", "second"]:
		format_dict[field] = "%02d" % format_dict[field]

	# Add the millisecond
	var unix_time: float = Time.get_unix_time_from_system()
	var millisecond: int = int((unix_time - int(unix_time)) * 1000.0)
	format_dict["millisecond"] = "%03d" % millisecond
	
	# Add the startup time to the format dictionary.
	var elapsed_millisecond: int = Time.get_ticks_msec()
	var startup_hour: int = elapsed_millisecond / 3_600_000
	var startup_minute: int = (elapsed_millisecond % 3_600_000) / 60_000
	var startup_second: int = (elapsed_millisecond % 60_000) / 1000
	var startup_millisecond: int = elapsed_millisecond % 1000
	format_dict["startup_hour"] = "%02d" % startup_hour
	format_dict["startup_minute"] = "%02d" % startup_minute
	format_dict["startup_second"] = "%02d" % startup_second
	format_dict["startup_millisecond"] = "%03d" % startup_millisecond

	message = "{formatted_time} {msg}".format({
		"formatted_time" : loggie.settings.format_timestamp.format(format_dict),
		"msg" : message
	})
	
	return message

## Adds the stack trace to the given [param message] and returns the modified version of it.
func _apply_format_stack(message : String) -> String:
	var loggie = get_logger()
	var stack_msg = loggie.stack()
	message = message + stack_msg.string()
	return message
