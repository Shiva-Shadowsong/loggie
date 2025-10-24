## Tests whether:
##[br]* The [member LoggieMsg.strict_type] will be enforced when [member LoggieMsg.dynamic_type] is set to false.
##[br]* Whether the [method LoggieMsg.type] correctly performs setting this functionality.
class_name TestEnforceStrictMsgType extends LoggieAutoTestCase

var received_msgs = []
	
func run() -> void:
	settings.log_level = LoggieEnums.LogLevel.DEBUG
	settings.default_channels = ["test_channel"]
	var test_channel = Loggie.get_channel("test_channel")
	test_channel.preprocess_flags = 0
	test_channel.message_received.connect(on_msg_received)
	
	## Should arrive at the target channel under type: LoggieEnums.MsgType.DEBUG
	Loggie.msg("0").debug()
	
	## Should arrive at the target channel under type: LoggieEnums.MsgType.INFO
	## even though it is sent as a debug message.
	Loggie.msg("1").type("info").debug()

	## Should not arrive at all, because the debug log level is now disabled,
	## even though it is set as type info:
	settings.log_level = LoggieEnums.LogLevel.INFO
	Loggie.msg("2").type("info").debug()
	
	# Await 2 frames for Loggie's internal deferred calls to go through.
	await get_tree().process_frame
	await get_tree().process_frame
	
	var failed_checks = false
	if received_msgs.size() == 2:
		for i in received_msgs.size():
			var received_msg : String = received_msgs[i].msg.string()
			var received_as_type : LoggieEnums.MsgType = received_msgs[i].type
			var expected_msg = str(i)
			var expected_type = LoggieEnums.MsgType.DEBUG if i == 0 else LoggieEnums.MsgType.INFO
			
			if not(received_msg == expected_msg and received_as_type == expected_type):
				c_print("❌ At index {i} - The received message should be '{expected_msg}' with type {expected_type}. Instead got: '{received_msg}' with type {received_type}".format({
					"i": i,
					"expected_msg": expected_msg,
					"expected_type": LoggieEnums.MsgType.keys()[expected_type],
					"received_msg": received_msg,
					"received_type": received_as_type
				}))
				failed_checks = true
	else:
		c_print("❌ Unexpected amount of messages received. Expected exactly 2. One of the test messages that shouldn't have been going through to the test_channel somehow arrived there.")
		failed_checks = true

	test_channel.message_received.disconnect(on_msg_received)
	
	if failed_checks:
		fail()
		return

	success()
	return

func on_msg_received(msg : LoggieMsg, type : LoggieEnums.MsgType) -> void:
	received_msgs.push_back({"msg": msg, "type": type})
