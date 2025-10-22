class_name VTestLogLevels extends LoggieVisualTestCase

func _init() -> void:
	title = "Log Levels"

func run() -> void:
	_console.add_text("Please verify that below, there are exactly {levels_count} messages, one for each Log Level, and that their styles and content are looking correct:".format({
		"levels_count": LoggieEnums.LogLevel.keys().size()
	}))
	var hsep = HSeparator.new()
	_console.add_content(hsep)
	send_test_messages()

## For each [LoggieEnums.LogLevel], sends a message whose string content is the same as the name
## of that log level, to that log level, with that message type. 
## Uses [LoggieMsg.output] to send the messages.
func send_test_messages() -> void:
	for log_lvl_name : String in LoggieEnums.LogLevel.keys():
		var log_lvl : LoggieEnums.LogLevel = LoggieEnums.LogLevel[log_lvl_name]
		var msg_type : LoggieEnums.MsgType = (log_lvl as LoggieEnums.MsgType)
		var msg = Loggie.msg(log_lvl_name)
		msg.channel("test_console")
		msg.output(log_lvl, msg_type)
