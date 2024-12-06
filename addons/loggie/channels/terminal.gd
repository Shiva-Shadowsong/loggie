class_name TerminalLoggieMsgChannel extends LoggieMsgChannel

func _init() -> void:
	self.ID = "terminal"
	self.preprocess_flags = 0 # For this type of channel, this will be applied dynamically by Loggie after it loads LoggieSettings.

func send(msg : LoggieMsg, msg_type : LoggieEnums.MsgType):
	var loggie = msg.get_logger()
	var text = LoggieTools.get_terminal_ready_string(msg.last_preprocess_result, loggie.settings.msg_format_mode)

	match loggie.settings.msg_format_mode:
		LoggieEnums.MsgFormatMode.ANSI, LoggieEnums.MsgFormatMode.BBCODE:
			print_rich(text)
		LoggieEnums.MsgFormatMode.PLAIN, _:
			print(text)

	# Dump a non-preprocessed terminal-ready version of the message in additional ways if that has been configured.
	if msg_type == LoggieEnums.MsgType.ERROR and loggie.settings.print_errors_to_console:
		push_error(LoggieTools.get_terminal_ready_string(msg.string(), LoggieEnums.MsgFormatMode.PLAIN))
	if msg_type == LoggieEnums.MsgType.WARNING and loggie.settings.print_warnings_to_console:
		push_warning(LoggieTools.get_terminal_ready_string(msg.string(), LoggieEnums.MsgFormatMode.PLAIN))
	if msg_type == LoggieEnums.MsgType.DEBUG and loggie.settings.use_print_debug_for_debug_msg:
		print_debug(LoggieTools.get_terminal_ready_string(msg.string(), loggie.settings.msg_format_mode))
