class_name TestLoggieMsgFormat extends LoggieAutoTestCase

func run() -> void:
	# Test formatting current segment.
	var msg = Loggie.msg("hello").msg("{pch}").format({
		"pch": "world"
	})
	var expected_msg = "helloworld"
	var received_msg = msg.string()
	if msg.string() != expected_msg:
		c_print("❌ Unexpected msg format received.\nExpected: {expected}\nReceived: {received}".format({
			"expected": expected_msg, "received": received_msg
		}))
		fail()
		return
	
	# Test formatting specific segment.
	var msg2 = Loggie.msg("hello").msg("{pch}").format_seg(1, {
		"pch": "world"
	})
	expected_msg = "helloworld"
	received_msg = msg2.string()
	if msg2.string() != expected_msg:
		c_print("❌ Unexpected msg format received.\nExpected: {expected}\nReceived: {received}".format({
			"expected": expected_msg, "received": received_msg
		}))
		fail()
		return
	
	# Test formatting entire message with a more complex case.
	var msg3 = Loggie.msg("{pch1}").msg("{pch1}").msg("{pch1}").format_all({
		"pch1": "{next_placeholder}",
	}).format_all({"next_placeholder": "hello"})
	expected_msg = "hellohellohello"
	received_msg = msg3.string()
	if msg3.string() != expected_msg:
		c_print("❌ Unexpected msg format received.\nExpected: {expected}\nReceived: {received}".format({
			"expected": expected_msg, "received": received_msg
		}))
		fail()
		return
	
	# Test formatting a preset.
	Loggie.preset("TestPreset1").color("red").bold().italic()
	var msg4 = Loggie.msg("{pch}").preset("TestPreset1").format({"pch": "hello world"})
	expected_msg = "[i][b][color=red]hello world[/color][/b][/i]"
	received_msg = msg4.string()
	if msg4.string() != expected_msg:
		c_print("❌ Unexpected msg format received.\nExpected: {expected}\nReceived: {received}".format({
			"expected": expected_msg, "received": received_msg
		}))
		fail()
		return

	success()
	return
