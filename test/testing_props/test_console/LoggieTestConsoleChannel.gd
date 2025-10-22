@tool
class_name LoggieTestConsoleChannel extends LoggieMsgChannel

var console : LoggieTestConsole

func _init() -> void:
	ID = "test_console"
	preprocess_flags = LoggieEnums.PreprocessStep.APPEND_TIMESTAMPS | LoggieEnums.PreprocessStep.APPEND_DOMAIN_NAME | LoggieEnums.PreprocessStep.APPEND_CLASS_NAME

func send(msg : LoggieMsg, _msg_type : LoggieEnums.MsgType):
	if not is_instance_valid(console):
		push_error("Attempt to send to the test_console channel failed. Test console is not valid or connected.")
		return

	var loggie = msg.get_logger()
	var text = LoggieTools.convert_string_to_format_mode(msg.last_preprocess_result, loggie.settings.msg_format_mode)
	console.add_text(text)
