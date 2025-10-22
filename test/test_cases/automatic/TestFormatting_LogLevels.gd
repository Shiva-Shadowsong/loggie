## Tests whether the formatting of all log levels works as intended after a message goes through
## the entire preprocessing phase.
class_name TestFormatting_LogLevels extends LoggieAutoTestCase

var msg_text = "test"

func run() -> void:
	settings.log_level = LoggieEnums.LogLevel.DEBUG
	settings.default_channels = ["test_channel"]
	var test_channel : LoggieMsgChannel = Loggie.get_channel("test_channel")
	test_channel.preprocess_flags = 0

	## Store each message that passes validation here.
	var msgs_passed_validation = []
	var expected_msgs_amount = LoggieEnums.LogLevel.keys().size()

	print_rich("\t Expecting to evaluate {expected_msgs_amount} messages on channel {target_channel}.".format({
		"expected_msgs_amount": expected_msgs_amount, "target_channel": Loggie.settings.default_channels
	}))
	
	var onMessageReceived : Callable = func(msg : LoggieMsg, type : LoggieEnums.MsgType):
		var log_level : LoggieEnums.LogLevel = type as LoggieEnums.LogLevel
		var expected_output : String = ""
		match log_level:
			LoggieEnums.LogLevel.ERROR:
				expected_output = Loggie.settings.format_error_msg.format({"msg": msg_text})
			LoggieEnums.LogLevel.WARN:
				expected_output = Loggie.settings.format_warning_msg.format({"msg": msg_text})
			LoggieEnums.LogLevel.NOTICE:
				expected_output = Loggie.settings.format_notice_msg.format({"msg": msg_text})
			LoggieEnums.LogLevel.INFO:
				expected_output = Loggie.settings.format_info_msg.format({"msg": msg_text})
			LoggieEnums.LogLevel.DEBUG:
				expected_output = Loggie.settings.format_debug_msg.format({"msg": msg_text})
		
		var outputtxt = "\t\t\tType: {type} - Top (received value) matches bottom (expected value)?\n\t\t\t\t'{msg}'\n\t\t\t\t'{expected}'\n\t\t\tResult:".format({
			"msg": msg.last_preprocess_result,
			"type": LoggieEnums.MsgType.keys()[type],
			"expected": expected_output
		})
		
		if msg.last_preprocess_result == expected_output:
			msgs_passed_validation.push_back(msg)
			outputtxt = outputtxt + " ✔️"
		else:
			outputtxt = outputtxt + " ❌"

		print(outputtxt)
	
	test_channel.message_received.connect(onMessageReceived)
	sendTestMessages()
	
	# Await 2 frames for Loggie's internal deferred calls to go through.
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Everything was fine if all 5 messages were captured.
	test_channel.message_received.disconnect(onMessageReceived)
	if msgs_passed_validation.size() < expected_msgs_amount:
		print("❌ Not all messages passed validation.")
		fail()
		return

	success()
	return

## For each [LoggieEnums.LogLevel], sends a message that will be evaluated by [method run].
## Uses [LoggieMsg.output] to send the messages.
func sendTestMessages() -> void:
	for log_lvl_name : String in LoggieEnums.LogLevel.keys():
		var log_lvl : LoggieEnums.LogLevel = LoggieEnums.LogLevel[log_lvl_name]
		var msg_type : LoggieEnums.MsgType = (log_lvl as LoggieEnums.MsgType)
		Loggie.msg(msg_text).preprocessed(true).output(log_lvl, msg_type)
