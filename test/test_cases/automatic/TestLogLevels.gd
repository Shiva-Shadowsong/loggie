## Tests whether all supported log levels:
## [br]* Whether sending a message to each of the possible log levels results in a configured channel successfully receiving a message.
## [br]* Messages configured for some log level correctly fail to output when that log level is not enabled.
class_name TestLogLevelOutputs extends LoggieAutoTestCase
	
func run() -> void:
	settings.log_level = LoggieEnums.LogLevel.DEBUG
	settings.default_channels = ["test_channel"]
	var test_channel : LoggieMsgChannel = Loggie.get_channel("test_channel")
	test_channel.preprocess_flags = 0
	
	## Store each message that passes validation here.
	var succesfulMessages = []
	
	# ------------------ SUBTEST 1 ------------------- ##
	# Test that all types of messages will properly arrive on a target channel.
	c_print("\t Expecting to receive {lvl_count} messages on channel {target_channel}.".format({
		"lvl_count": LoggieEnums.LogLevel.size(), "target_channel": Loggie.settings.default_channels
	}), true, true)
	
	var onMessageReceived_Subtest1 : Callable = func(msg : LoggieMsg, type : LoggieEnums.MsgType):
		if msg.string() == LoggieEnums.MsgType.keys()[type]:
			print_rich("\t\t[color=slate_gray]Message received:[/color] ", msg.string())
			succesfulMessages.push_back(msg)
	
	test_channel.message_received.connect(onMessageReceived_Subtest1)
	sendTestMessages()
	
	# Await 2 frames for Loggie's internal deferred calls to go through.
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Everything was fine if all 5 messages were captured.
	test_channel.message_received.disconnect(onMessageReceived_Subtest1)
	if succesfulMessages.size() < 5:
		fail()
		c_print("\t Not enough messages were received.", false, true)
		return
	
	# ------------------ SUBTEST 2 ------------------- #
	# Test that all types of messages will respect the debug level they are configured to run on.

	c_print("\n\t Now enabling each log level one by one, and sending one message of ALL loglevels while that level is enabled.".format({
		"lvl_count": LoggieEnums.LogLevel.size(), "target_channel": Loggie.settings.default_channels
	}), true, true)

	var failedAttempts = {}
	
	var onLogAttempted_Subtest2 = func(msg : LoggieMsg, _preprocessed_content : String, attempt_result : LoggieEnums.LogAttemptResult):
		c_print("\t\t\t[color=slate_gray]Log attempted: {msg} | Result: {result}[/color]".format({
			"msg": msg.string(),
			"result": LoggieEnums.LogAttemptResult.keys()[attempt_result]
		}), true, true)

		if attempt_result == LoggieEnums.LogAttemptResult.LOG_LEVEL_INSUFFICIENT:
			failedAttempts[msg] = attempt_result

	Loggie.log_attempted.connect(onLogAttempted_Subtest2)

	var expectedFailedAttempts = 0
	for logLevel : LoggieEnums.LogLevel in LoggieEnums.LogLevel.values():
		expectedFailedAttempts = (LoggieEnums.LogLevel.size() - 1) - int(logLevel)

		if expectedFailedAttempts <= 0:
			c_print("\t\tNo failures expected at level {level}.".format({"level": LoggieEnums.LogLevel.keys()[logLevel]}), false, true)
			continue

		c_print("\t\tChecking how many messages will fail to pass the log level check for {level} level. Expecting {expectedFailCount} [color=slate_gray]LOG_LEVEL_INSUFFICIENT[/color] failures.".format({
			"expectedFailCount": expectedFailedAttempts,
			"level": LoggieEnums.LogLevel.keys()[logLevel]
		}), true, true)

		Loggie.settings.log_level = logLevel
		sendTestMessages()
		await get_tree().create_timer(0.2).timeout # Wait a bit for the channel to receive all the messages and make necessary recordings.
		if failedAttempts.keys().size() != expectedFailedAttempts:
			c_print("\t❌ Expected to fail {expectedFailCount} times. Instead, failed {failCount} times.".format({
				"expectedFailCount": expectedFailedAttempts,
				"l": LoggieEnums.LogLevel.keys()[logLevel],
				"failCount": failedAttempts.keys().size()
			}), true, false)
			fail()
			Loggie.log_attempted.disconnect(onLogAttempted_Subtest2)
			return
		else:
			failedAttempts.clear()

	Loggie.log_attempted.disconnect(onLogAttempted_Subtest2)
	
	success()
	return

## For each [LoggieEnums.LogLevel], sends a message whose string content is the same as the name
## of that log level, to that log level, with that message type. 
## Uses [LoggieMsg.output] to send the messages.
func sendTestMessages() -> void:
	for log_lvl_name : String in LoggieEnums.LogLevel.keys():
		var log_lvl : LoggieEnums.LogLevel = LoggieEnums.LogLevel[log_lvl_name]
		var msg_type : LoggieEnums.MsgType = (log_lvl as LoggieEnums.MsgType)
		var msg = Loggie.msg(log_lvl_name)
		msg.output(log_lvl, msg_type)
