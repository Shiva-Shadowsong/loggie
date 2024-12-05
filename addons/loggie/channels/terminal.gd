class_name TerminalLoggieMsgChannel extends LoggieMsgChannel

func _init() -> void:
	self.ID = "terminal"
	self.preprocess_flags = 0 # For this type of channel, this will be applied dynamically by Loggie after it loads LoggieSettings.

func send(msg : LoggieMsg, msg_type : LoggieEnums.MsgType):
	var loggie = msg.get_logger()
	var text = LoggieTools.get_terminal_ready_string(msg.last_preprocess_result, loggie.settings.terminal_mode)

	match loggie.settings.terminal_mode:
		LoggieEnums.TerminalMode.ANSI, LoggieEnums.TerminalMode.BBCODE:
			print_rich(text)
		LoggieEnums.TerminalMode.PLAIN, _:
			print(text)

	# Dump a non-preprocessed terminal-ready version of the message in additional ways if that has been configured.
	if msg_type == LoggieEnums.MsgType.ERROR and loggie.settings.print_errors_to_console:
		push_error(LoggieTools.get_terminal_ready_string(msg.string(), LoggieEnums.TerminalMode.PLAIN))
	if msg_type == LoggieEnums.MsgType.WARNING and loggie.settings.print_warnings_to_console:
		push_warning(LoggieTools.get_terminal_ready_string(msg.string(), LoggieEnums.TerminalMode.PLAIN))
	if msg_type == LoggieEnums.MsgType.DEBUG and loggie.settings.use_print_debug_for_debug_msg:
		print_debug(LoggieTools.get_terminal_ready_string(msg.string(), loggie.settings.terminal_mode))
