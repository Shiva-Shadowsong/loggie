## Tests whether all color related features and shortcuts work correctly.
class_name TestColor extends LoggieAutoTestCase

var msg_text = "test"
var test_color_values = ["red", "ff0000", "#ff0000", Color.RED, "invalid123"]
	
func run() -> void:
	settings.log_level = LoggieEnums.LogLevel.DEBUG
	settings.default_channels = ["test_channel"]
	var test_channel : LoggieMsgChannel = Loggie.get_channel("test_channel")
	test_channel.preprocess_flags = 0

	## Store each message that passes validation here.
	var msgs_passed_validation = []
	var expected_msgs_amount = LoggieEnums.LogLevel.keys().size() * test_color_values.size()

	print_rich("\t Expecting to receive {expected_msgs_amount} messages on channel {target_channel}.".format({
		"expected_msgs_amount": expected_msgs_amount, "target_channel": Loggie.settings.default_channels
	}))
	
	var onMessageReceived : Callable = func(msg : LoggieMsg, type : LoggieEnums.MsgType):
		var used_color_value = msg.get_meta("used_color_value")
		var expected_msg_string = "[color={colorstr}]{msg}[/color]".format({
			"colorstr": used_color_value if !(used_color_value is Color) else used_color_value.to_html(), 
			"msg": msg_text
		})
		
		var outputtxt = "\t\t\tType: {type} - Top (received value) matches bottom (expected value)?\n\t\t\t\t'{msg}'\n\t\t\t\t'{expected}'\n\t\t\tResult:".format({
			"msg": msg.string(),
			"type": LoggieEnums.MsgType.keys()[type],
			"expected": expected_msg_string
		})
		
		if msg.string() == expected_msg_string:
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

## For each [LoggieEnums.LogLevel], sends a set of messages whose colors are configured
## with every expected type of color value.
## Uses [LoggieMsg.output] to send the messages.
func sendTestMessages() -> void:
	for log_lvl_name : String in LoggieEnums.LogLevel.keys():
		var log_lvl : LoggieEnums.LogLevel = LoggieEnums.LogLevel[log_lvl_name]
		var msg_type : LoggieEnums.MsgType = (log_lvl as LoggieEnums.MsgType)
		
		var msgs = []
		
		for value in test_color_values:
			var msg = Loggie.msg(msg_text).color(value)
			msg.set_meta("used_color_value", value)
			msgs.push_back(msg)
		
		for msg : LoggieMsg in msgs:
			msg.preprocessed(false).output(log_lvl, msg_type)
