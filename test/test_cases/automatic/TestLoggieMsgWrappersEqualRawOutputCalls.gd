## Tests whether:
##[br]* Sending a message using `output` directly produces the exact same result as using a
##Loggie shortcut (e.g. Loggie.info) or LoggieMsg wrapper (e.g. LoggieMsg.info).
##[br]* A Loggie shortcut and LoggieMsg wrapper exists for every possible log level.

class_name TestLoggieMsgWrappersEqualRawOutputCalls extends LoggieAutoTestCase

var received_msgs = []
var expected_msgs = []
	
func run() -> void:
	settings.log_level = LoggieEnums.LogLevel.DEBUG
	settings.default_channels = ["test_channel"]
	var test_channel : LoggieMsgChannel = Loggie.get_channel("test_channel")
	test_channel.message_received.connect(on_msg_received)
	test_channel.preprocess_flags = 0

	var msg_txt = "[b]test[/b]"
	var expected_msg = "[b]test[/b]"

	# Subtest 0
	expected_msgs.push_back(expected_msg)
	Loggie.msg(msg_txt).info()

	# Subtest 1
	expected_msgs.push_back(expected_msg)
	Loggie.info(msg_txt)
	
	# Subtest 2
	expected_msgs.push_back(expected_msg)
	Loggie.msg(msg_txt).output(LoggieEnums.LogLevel.INFO, LoggieEnums.MsgType.INFO)


	if expected_msgs.size() != received_msgs.size():
		c_print("❌ Received less messages than expected. Can't proceed. Expected {expected_amount} {expected}, got: {received_amount} {received}".format({
			"expected_amount": expected_msgs.size(),
			"expected": expected_msgs,
			"received_amount": received_msgs.size(),
			"received": received_msgs,
		}))
		fail()
		return

	var match_failure = false
	for index in expected_msgs.size():
		expected_msg = expected_msgs[index]
		var received_msg = received_msgs[index]
		if expected_msg != received_msg:
			c_print("❌ In sub-test {index}:\n\tExpected: `{expected}`\n\tReceived: `{received}`".format({
				"index": index,
				"expected": expected_msg,
				"received": received_msg,
			}), false, false)
			match_failure = true
		else:
			c_print("✅ In sub-test {index}:\n\tExpected: `{expected}`\n\tReceived: `{received}`".format({
				"index": index,
				"expected": expected_msg,
				"received": received_msg,
			}), false, true)
	
	if match_failure:
		fail()
		return

	await get_tree().process_frame
	await get_tree().process_frame
	test_channel.message_received.disconnect(on_msg_received)
	
	# Now check if proper wrappers exist.
	for log_level_name_from_enum : String in LoggieEnums.LogLevel.keys():
		var log_level_name : String = log_level_name_from_enum.to_lower()
		# Check if 'Loggie' has a shortcut.
		if !Loggie.has_method(log_level_name):
			c_print("❌ A shortcut method called '{name}' should be present on the `Loggie` class, allowing to quickly send messages with that log level.".format({"name": log_level_name}))
			fail()
			return
		
		# Check if 'LoggieMsg' has a wrapper.
		var temp_msg = LoggieMsg.new()
		if !temp_msg.has_method(log_level_name):
			c_print("❌ A wrapper method called '{name}' should be present on the `LoggieMsg` class, allowing to quickly send messages with that log level.".format({"name": log_level_name}))
			fail()
			return
	
	success()
	return

func on_msg_received(msg : LoggieMsg, _type : LoggieEnums.MsgType):
	received_msgs.push_back(msg.last_preprocess_result)
