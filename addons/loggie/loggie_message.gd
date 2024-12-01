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

## Whether this message should be preprocessed and modified during [method output].
var preprocess : bool = true

## Stores a reference to the logger that generated this message, from which we need to read settings and other data.
## This variable should be set with [method use_logger] before an attempt is made to log this message out.
var _logger : Variant

func _init(message = "", arg1 = null, arg2 = null, arg3 = null, arg4 = null, arg5 = null) -> void:
	self.content[current_segment_index] = LoggieTools.concatenate_msg_and_args(message, arg1, arg2, arg3, arg4, arg5)

## Returns a reference to the logger object that created this message.
func get_logger() -> Variant:
	return self._logger

## Sets this message to use the given [param logger] as the logger from which it will be reading
## settings. The given logger should be of class [Loggie] or an extension of it.
func use_logger(logger_to_use : Variant) -> LoggieMsg:
	self._logger = logger_to_use
	return self

## Outputs the given string [param msg] at the given output [param level] to the standard output using either [method print_rich] or [method print].
## The domain from which the message is considered to be coming can be provided via [param target_domain].
## The classification of the message can be provided via [param msg_type], as certain types need extra handling and treatment.
## It also does a number of changes to the given [param msg] based on various Loggie settings.
## Designed to be called internally. You should consider using [method info], [method error], [method warn], [method notice], [method debug] instead.
func output(level : LoggieEnums.LogLevel, message : String, target_domain : String = "", msg_type : LoggieEnums.MsgType = LoggieEnums.MsgType.STANDARD) -> void:
	var loggie = get_logger()
	
	if loggie == null:
		push_error("Attempt to log output with an invalid _logger. Make sure to call LoggieMsg.use_logger to set the appropriate logger before working with the message.")
		return
		
	if loggie.settings == null:
		push_error("Attempt to use a _logger with invalid settings.")
		return

	# We don't output the message if the settings dictate that messages of that level shouldn't be outputted.
	if level > loggie.settings.log_level:
		loggie.log_attempted.emit(self, message, LoggieEnums.LogAttemptResult.LOG_LEVEL_INSUFFICIENT)
		return

	# We don't output the message if the domain from which it comes is not enabled.
	if not loggie.is_domain_enabled(target_domain):
		loggie.log_attempted.emit(self, message, LoggieEnums.LogAttemptResult.DOMAIN_DISABLED)
		return

	# Apply the matching formatting to the message based on the log level.
	match level:
		LoggieEnums.LogLevel.ERROR:
			message = loggie.settings.format_error_msg.format({"msg": message})
		LoggieEnums.LogLevel.WARN:
			message = loggie.settings.format_warning_msg.format({"msg": message})
		LoggieEnums.LogLevel.NOTICE:
			message = loggie.settings.format_notice_msg.format({"msg": message})
		LoggieEnums.LogLevel.INFO:
			message = loggie.settings.format_info_msg.format({"msg": message})
		LoggieEnums.LogLevel.DEBUG:
			message = loggie.settings.format_debug_msg.format({"msg": message})

	# Enter the preprocess tep unless it is disabled.
	if self.preprocess:
		# We append the name of the domain if that setting is enabled.
		if !target_domain.is_empty() and loggie.settings.output_message_domain == true:
			message = loggie.settings.format_domain_prefix.format({"domain" : target_domain, "msg" : message})

		# We prepend the name of the class that called the function which resulted in this output being generated
		# (if Loggie settings are configured to do so).
		if loggie.settings.derive_and_show_class_names == true and OS.has_feature("debug"):
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

		# We prepend a timestamp to the message (if Loggie settings are configured to do so).
		if loggie.settings.output_timestamps == true:
			var format_dict : Dictionary = Time.get_datetime_dict_from_system(loggie.settings.timestamps_use_utc)
			for field in ["month", "day", "hour", "minute", "second"]:
				format_dict[field] = "%02d" % format_dict[field]
			message = "{formatted_time} {msg}".format({
				"formatted_time" : loggie.settings.format_timestamp.format(format_dict),
				"msg" : message
			})

	# Prepare the preprocessed message to be output in the terminal mode of choice.
	message = LoggieTools.get_terminal_ready_string(message, loggie.settings.terminal_mode)
	
	# Output the preprocessed message.
	match loggie.settings.terminal_mode:
		LoggieEnums.TerminalMode.ANSI, LoggieEnums.TerminalMode.BBCODE:
			print_rich(message)
		LoggieEnums.TerminalMode.PLAIN, _:
			print(message)

	# Dump a non-preprocessed terminal-ready version of the message in additional ways if that has been configured.
	if msg_type == LoggieEnums.MsgType.ERROR and loggie.settings.print_errors_to_console:
		push_error(LoggieTools.get_terminal_ready_string(self.string(), LoggieEnums.TerminalMode.PLAIN))
	if msg_type == LoggieEnums.MsgType.WARNING and loggie.settings.print_warnings_to_console:
		push_warning(LoggieTools.get_terminal_ready_string(self.string(), LoggieEnums.TerminalMode.PLAIN))
	if msg_type == LoggieEnums.MsgType.DEBUG and loggie.settings.use_print_debug_for_debug_msg:
		print_debug(LoggieTools.get_terminal_ready_string(self.string(), loggie.settings.terminal_mode))

	loggie.log_attempted.emit(self, message, LoggieEnums.LogAttemptResult.SUCCESS)

## Outputs this message from Loggie as an Error type message.
## The [Loggie.settings.log_level] must be equal to or higher to the ERROR level for this to work.
func error() -> LoggieMsg:
	output(LoggieEnums.LogLevel.ERROR, self.string(), self.domain_name, LoggieEnums.MsgType.ERROR)
	return self

## Outputs this message from Loggie as an Warning type message.
## The [Loggie.settings.log_level] must be equal to or higher to the WARN level for this to work.
func warn() -> LoggieMsg:
	output(LoggieEnums.LogLevel.WARN, self.string(), self.domain_name, LoggieEnums.MsgType.WARNING)
	return self

## Outputs this message from Loggie as an Notice type message.
## The [Loggie.settings.log_level] must be equal to or higher to the NOTICE level for this to work.
func notice() -> LoggieMsg:
	output(LoggieEnums.LogLevel.NOTICE, self.string(), self.domain_name)
	return self

## Outputs this message from Loggie as an Info type message.
## The [Loggie.settings.log_level] must be equal to or higher to the INFO level for this to work.
func info() -> LoggieMsg:
	output(LoggieEnums.LogLevel.INFO, self.string(), self.domain_name)
	return self

## Outputs this message from Loggie as a Debug type message.
## The [Loggie.settings.log_level] must be equal to or higher to the DEBUG level for this to work.
func debug() -> LoggieMsg:
	output(LoggieEnums.LogLevel.DEBUG, self.string(), self.domain_name, LoggieEnums.MsgType.DEBUG)
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

## Stylizes the current segment of this message as a header.
func header() -> LoggieMsg:
	var loggie = get_logger()
	self.content[current_segment_index] = loggie.settings.format_header.format({"msg": self.content[current_segment_index]})
	return self

## Constructs a decorative box with the given horizontal padding around the current segment
## of this message. Messages containing a box are not going to be preprocessed, so they are best
## used only as a special header or decoration.
func box(h_padding : int = 4):
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
	self.content[current_segment_index] = self.content[current_segment_index] + LoggieTools.concatenate_msg_and_args(message, arg1, arg2, arg3, arg4, arg5)
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

## Creates a new segment in this message and sets its content to the given message.
## Acts as a shortcut for calling [method endseg] + [method add].
func msg(message = "", arg1 = null, arg2 = null, arg3 = null, arg4 = null, arg5 = null) -> LoggieMsg:
	self.endseg()
	self.content[current_segment_index] = LoggieTools.concatenate_msg_and_args(message, arg1, arg2, arg3, arg4, arg5)
	return self

## Sets whether this message should be preprocessed and potentially modified with prefixes and suffixes during [method output].
## If turned off, while outputting this message, Loggie will skip the steps where it appends the messaage domain, class name, timestamp, etc.
## Whether preprocess is set to true doesn't affect the final conversion from RICH to ANSI or PLAIN, which always happens 
## under some circumstances that are based on other settings.
func preprocessed(shouldPreprocess : bool) -> LoggieMsg:
	self.preprocess = shouldPreprocess
	return self
