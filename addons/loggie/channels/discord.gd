class_name TerminalChannel extends LoggieMsgChannel

func dispatch(message: LoggieMsg):
	print(message.message)
