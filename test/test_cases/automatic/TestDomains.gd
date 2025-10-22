## Tests whether:
##[br]* Sending a message to a domain works.
##[br]* Sending a message to a domain fails to work if a domain is disabled.
##[br]* A domain prefix is appended if configured to do so.
##[br]* A domain configured to send messages to a custom channel list sends them only to those channels.
class_name TestDomains extends LoggieAutoTestCase

var received_msgs = []
	
func run() -> void:
	settings.log_level = LoggieEnums.LogLevel.DEBUG
	settings.default_channels = ["test_channel"]
	var test_channel : LoggieMsgChannel = Loggie.get_channel("test_channel")
	test_channel.preprocess_flags = LoggieEnums.PreprocessStep.APPEND_DOMAIN_NAME
	test_channel.message_received.connect(on_msg_received)
	
	Loggie.set_domain_enabled("TestDomains1", true)
	Loggie.msg("test1").domain("TestDomains1").info()
	Loggie.set_domain_enabled("TestDomains1", false)
	Loggie.msg("test2").domain("TestDomains1").info()
	
	settings.default_channels = []
	Loggie.set_domain_enabled("TestDomains2", true, ["test_channel"])
	Loggie.msg("test3").domain("TestDomains2").info()
	Loggie.set_domain_enabled("TestDomains2", false, ["test_channel"])
	Loggie.msg("test4").domain("TestDomains2").info()

	# Await 2 frames for Loggie's internal deferred calls to go through.
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Everything was fine if exactly 2 "test1" and "test3" messages were captured.
	test_channel.message_received.disconnect(on_msg_received)
	
	var validation_passed = (received_msgs.size() == 2 and received_msgs.has("test1") and received_msgs.has("test3"))
	if !validation_passed:
		c_print("❌ Messages that shouldn't have been received were received. Expected [\"test1\",\"test3\"], got: {msgs}".format({"msgs": received_msgs}))
		fail()
		return
	
	# Now let's see if prefix is appended correctly.
	received_msgs = []
	test_channel.message_received.connect(on_msg_received2)
	Loggie.set_domain_enabled("TestDomains3", true, ["test_channel"])
	Loggie.msg("test5").domain("TestDomains3").info()
	
	# Await 2 frames for Loggie's internal deferred calls to go through.
	await get_tree().process_frame
	await get_tree().process_frame
	test_channel.message_received.disconnect(on_msg_received2)
	
	if received_msgs.size() != 1:
		fail()
		return

	success()
	return

func on_msg_received(msg : LoggieMsg, _type : LoggieEnums.MsgType):
	received_msgs.push_back(msg.string())
	
func on_msg_received2(msg : LoggieMsg, _type : LoggieEnums.MsgType):
	var expected_msg = Loggie.settings.format_domain_prefix.format({"domain" : "TestDomains3", "msg" : "test5"})
	c_print("Expecting to receive a message: {expected}".format({"expected": expected_msg}), false, true)
	if msg.last_preprocess_result == expected_msg:
		received_msgs.push_back(msg.string())
		c_print("Received.", false, true)
	else:
		c_print("❌ Received unexpected message format: {received}".format({"received": msg.string()}))
