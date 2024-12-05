class_name DiscordChannel extends LoggieMsgChannel

func dispatch(message: LoggieMsg):
	var loggie = message.get_logger()
	
	# fire webhook
	pass

	# Dump a non-preprocessed terminal-ready version of the message in additional ways if that has been configured.
	#if msg_type == LoggieEnums.MsgType.ERROR and loggie.settings.print_errors_to_console:
		#push_error(LoggieTools.get_terminal_ready_string(self.string(), LoggieEnums.TerminalMode.PLAIN))
	#if msg_type == LoggieEnums.MsgType.WARNING and loggie.settings.print_warnings_to_console:
		#push_warning(LoggieTools.get_terminal_ready_string(self.string(), LoggieEnums.TerminalMode.PLAIN))
	#if msg_type == LoggieEnums.MsgType.DEBUG and loggie.settings.use_print_debug_for_debug_msg:
		#print_debug(LoggieTools.get_terminal_ready_string(self.string(), loggie.settings.terminal_mode))
