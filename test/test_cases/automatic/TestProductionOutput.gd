## Tests whether:
##[br]* Applying production-only settings results in expected outputs that are stripped of stylings.
class_name TestProductionOutput extends LoggieAutoTestCase

var received_msgs = []
var expected_msgs = []
var msg_txt = "test"
	
func run() -> void:
	settings.log_level = LoggieEnums.LogLevel.DEBUG
	settings.default_channels = ["test_channel"]
	var test_channel : LoggieMsgChannel = Loggie.get_channel("test_channel")
	test_channel.message_received.connect(on_msg_received)
	test_channel.preprocess_flags = LoggieEnums.PreprocessStep.APPEND_CLASS_NAME
	
	# SUBTEST 0:
	var expected_output = "[color=cyan][i][b]{msg_txt}[/b][/i][/color]  {msg_txt}".format({"msg_txt": msg_txt})
	expected_output = "[b][color=red][ERROR]:[/color][/b] {msg}".format({
		"msg": expected_output
	})
	expected_output = "[b]({class_name})[/b] {msg}".format({
		"class_name" : "TestProductionOutput",
		"msg" : expected_output,
	})
	expected_msgs.push_back(expected_output)
	Loggie.msg(msg_txt).bold().italic().color("cyan").space(2).msg(msg_txt).error()
	
	# SUBTEST 1:
	Loggie.apply_production_optimal_settings()
	expected_output = "({class_name}) [ERROR]: {msg}  {msg}".format({
		"class_name" : "TestProductionOutput",
		"msg" : msg_txt,
	})

	expected_msgs.push_back(expected_output)
	Loggie.msg(msg_txt).bold().italic().color("cyan").space(2).msg(msg_txt).error()

	# Await 2 frames for Loggie's internal deferred calls to go through.
	await get_tree().process_frame
	await get_tree().process_frame
	test_channel.message_received.disconnect(on_msg_received)

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
		var expected_msg = expected_msgs[index]
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

	success()
	return

func on_msg_received(msg : LoggieMsg, _type : LoggieEnums.MsgType):
	var converted = LoggieTools.convert_string_to_format_mode(msg.last_preprocess_result, Loggie.settings.msg_format_mode)
	received_msgs.push_back(converted)
