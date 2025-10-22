## Tests whether:
##[br]* A class name can be derived from a current execution context, its parent class, or its grandparent class.
##[br]* Tests both with modern approach and legacy approach for old versions.
##[br]* Tests that the related preprocess flag works as intended.
class_name TestClassNameDerivation extends LoggieAutoTestCase

var received_msgs = []
var expected_msgs = []
var msg_format = "[b]({class_name})[/b] {msg}"
	
func run() -> void:
	settings.log_level = LoggieEnums.LogLevel.DEBUG
	settings.default_channels = ["test_channel"]
	var test_channel : LoggieMsgChannel = Loggie.get_channel("test_channel")
	test_channel.message_received.connect(on_msg_received)
	
	var talker : LoggieTalker = load("uid://de25rhyt1674b").new()
	var talkerChild : LoggieTalker = load("uid://c7dbxvqk3xjgl").new()
	var talkerGrandchild : LoggieTalker = load("uid://dlrnralefgf3s").new()
	var namedChild : LoggieTalkerNamedChild = load("uid://cieg3fd4rkcdc").new()
	var namedGrandchild : LoggieTalkerNamedGrandchild = load("uid://nh6k3bjubpd4").new()
	var namelessTalker : Node = preload("uid://c6u41yu1thus0").new()
	
	# SUBTEST 0:
	# Since we're sending this message from the class named 'LoggieTalker',
	# That should be the name that's displayed.
	Loggie.class_names.clear()
	test_channel.preprocess_flags = LoggieEnums.PreprocessStep.APPEND_CLASS_NAME
	var expected_class_name = "LoggieTalker"
	var msg_txt = "test"
	var expected_output = msg_format.format({"class_name" : expected_class_name, "msg" : msg_txt})
	expected_msgs.push_back(expected_output)
	talker.say(msg_txt)
	
	# SUBTEST 1:
	# Now let's disable preprocessing for APPEND_CLASS_NAME.
	# Now we expect only to receive `msg_txt`.
	Loggie.class_names.clear()
	test_channel.preprocess_flags = 0
	expected_output = msg_txt
	expected_msgs.push_back(expected_output)
	talker.say(msg_txt)
	
	# SUBTEST 2:
	# Now let's try to send a message from LoggieTalker's inner class 'InnerLoggieTalker'.
	# Unfortunately, Godot won't recognize the Inner class' name (or maybe Loggie still isn't implemented properly to extract it),
	# therefore, for now, we expect to see "LoggieTalker" here.
	Loggie.class_names.clear()
	test_channel.preprocess_flags = LoggieEnums.PreprocessStep.APPEND_CLASS_NAME
	expected_output = msg_format.format({"class_name" : "LoggieTalker", "msg" : msg_txt})
	expected_msgs.push_back(expected_output)
	talker.say_from_inner(msg_txt)
	
	# SUBTEST 3:
	# Now let's try to send a message from an instance of 'LoggieTalkerChild'.
	# This class has no 'class_name', so a proxy will be used. Let's try out all 3 proxies.
	# Starting with proxy: BASE_TYPE
	# This proxy should extract the name from the Base Type of the object, referring to its
	# closest named parent class. In this case, that should be "LoggieTalker" since "LoggieTalkerChild" extends it.
	Loggie.class_names.clear()
	test_channel.preprocess_flags = LoggieEnums.PreprocessStep.APPEND_CLASS_NAME
	Loggie.settings.nameless_class_name_proxy = LoggieEnums.NamelessClassExtensionNameProxy.BASE_TYPE
	expected_output = msg_format.format({"class_name" : "LoggieTalker", "msg" : msg_txt})
	expected_msgs.push_back(expected_output)
	talkerChild.say(msg_txt)

	# SUBTEST 4:
	# Now let's try the same as above but with a truly nameless talker.
	# Generally, this should be the name of the script, so "Node".
	Loggie.class_names.clear()
	Loggie.settings.nameless_class_name_proxy = LoggieEnums.NamelessClassExtensionNameProxy.BASE_TYPE
	expected_output = msg_format.format({"class_name" : "Node", "msg" : msg_txt})
	expected_msgs.push_back(expected_output)
	namelessTalker.say(msg_txt)
	
	# SUBTEST 5:
	# Now let's try the same with the SCRIPT_NAME proxy.
	# Generally, this should be the name of the script, so "LoggieTalkerChild.gd".
	# However, even though LoggieTalkerChild is nameless, it has a named parent, so the name of the parent will be used.
	Loggie.class_names.clear()
	Loggie.settings.nameless_class_name_proxy = LoggieEnums.NamelessClassExtensionNameProxy.SCRIPT_NAME
	expected_output = msg_format.format({"class_name" : "LoggieTalker", "msg" : msg_txt})
	expected_msgs.push_back(expected_output)
	talkerChild.say(msg_txt)
	
	# SUBTEST 6:
	# Now let's try the same as above but with a truly nameless talker.
	# Generally, this should be the name of the script, so "LoggieNamelessTalker.gd".
	Loggie.class_names.clear()
	Loggie.settings.nameless_class_name_proxy = LoggieEnums.NamelessClassExtensionNameProxy.SCRIPT_NAME
	expected_output = msg_format.format({"class_name" : "LoggieNamelessTalker.gd", "msg" : msg_txt})
	expected_msgs.push_back(expected_output)
	namelessTalker.say(msg_txt)
	
	# SUBTEST 7:
	# Now let's try the same with the NOTHING proxy.
	# That means since there is no class_name, and we don't want to use anything as a proxy, there should be no prefix.
	Loggie.class_names.clear()
	Loggie.settings.nameless_class_name_proxy = LoggieEnums.NamelessClassExtensionNameProxy.NOTHING
	expected_output = msg_txt
	expected_msgs.push_back(expected_output)
	namelessTalker.say(msg_txt)
	
	# SUBTEST 8:
	# Now let's try the BASE_TYPE proxy on a class that:
	# Has no name. Extends another class that has no name, which extends a class with a name.
	# Since it has no name, it should try to find name of first named parent class, which should be its grandparent "LoggieTalker".
	Loggie.class_names.clear()
	Loggie.settings.nameless_class_name_proxy = LoggieEnums.NamelessClassExtensionNameProxy.BASE_TYPE
	expected_output = msg_format.format({"class_name" : "LoggieTalker", "msg" : msg_txt})
	expected_msgs.push_back(expected_output)
	talkerGrandchild.say(msg_txt)
	
	# SUBTEST 9:
	# Now let's try the same with the SCRIPT_NAME proxy.
	# Since it has no name, it should try to find name of first named parent class, which should be its grandparent "LoggieTalker".
	# Since that grandparent has a name, its name will be used, not the script name.
	Loggie.class_names.clear()
	Loggie.settings.nameless_class_name_proxy = LoggieEnums.NamelessClassExtensionNameProxy.SCRIPT_NAME
	expected_output = msg_format.format({"class_name" : "LoggieTalker", "msg" : msg_txt})
	expected_msgs.push_back(expected_output)
	talkerGrandchild.say(msg_txt)
	
	# SUBTEST 10:
	# Now let's try the BASE_TYPE proxy on a class that:
	# Has a name, but extends another custom class with a name.
	# It should still use its own class name, so it should be "LoggieTalkerNamedChild".
	Loggie.class_names.clear()
	Loggie.settings.nameless_class_name_proxy = LoggieEnums.NamelessClassExtensionNameProxy.BASE_TYPE
	expected_output = msg_format.format({"class_name" : "LoggieTalkerNamedChild", "msg" : msg_txt})
	expected_msgs.push_back(expected_output)
	namedChild.say(msg_txt)
	
	# SUBTEST 11:
	# Now let's try the BASE_TYPE proxy on a class that:
	# Has a name, but extends another custom class that has a name, which extends yet another custom class that has a name.
	# It should still use its own class name, so it should be "LoggieTalkerNamedGrandchild".
	Loggie.class_names.clear()
	Loggie.settings.nameless_class_name_proxy = LoggieEnums.NamelessClassExtensionNameProxy.BASE_TYPE
	expected_output = msg_format.format({"class_name" : "LoggieTalkerNamedGrandchild", "msg" : msg_txt})
	expected_msgs.push_back(expected_output)
	namedGrandchild.say(msg_txt)
	
	# SUBTEST 12:
	# Now let's try the BASE_TYPE proxy on a class that is an Inner class found in the grandparent of the caller:
	# Since the Inner class is the caller, it should find the BASE_TYPE in this named grandparent and use its name.
	Loggie.class_names.clear()
	Loggie.settings.nameless_class_name_proxy = LoggieEnums.NamelessClassExtensionNameProxy.BASE_TYPE
	expected_output = msg_format.format({"class_name" : "LoggieTalkerNamedGrandchild", "msg" : msg_txt})
	expected_msgs.push_back(expected_output)
	namedGrandchild.say_from_inner_two(msg_txt)
	
	# SUBTEST 13:
	# Now let's try the BASE_TYPE proxy on a class that is an autoloaded signleton.
	Loggie.class_names.clear()
	Loggie.settings.nameless_class_name_proxy = LoggieEnums.NamelessClassExtensionNameProxy.BASE_TYPE
	expected_output = msg_format.format({"class_name" : "Node", "msg" : msg_txt})
	expected_msgs.push_back(expected_output)
	LoggieAutoloadedTalker.say(msg_txt)
	
	# SUBTEST 14:
	# Now let's try the SCRIPT_NAME proxy on a class that is an autoloaded signleton.
	Loggie.class_names.clear()
	Loggie.settings.nameless_class_name_proxy = LoggieEnums.NamelessClassExtensionNameProxy.SCRIPT_NAME
	expected_output = msg_format.format({"class_name" : "LoggieAutoloadedTalker.gd", "msg" : msg_txt})
	expected_msgs.push_back(expected_output)
	LoggieAutoloadedTalker.say(msg_txt)

	# Await 2 frames for Loggie's internal deferred calls to go through.
	await get_tree().process_frame
	await get_tree().process_frame
	test_channel.message_received.disconnect(on_msg_received)
	
	# Validate.
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

	# Finally, let's check if both the modern and legacy approach for class_name extraction yield the same results.
	var comparison_failure = false
	Loggie.class_names.clear()

	var script_name_modern = LoggieTools.get_class_name_from_script(LoggieAutoloadedTalker.get_script(), LoggieEnums.NamelessClassExtensionNameProxy.SCRIPT_NAME)
	var script_name_legacy = LoggieTools.extract_class_name_from_gd_script(LoggieAutoloadedTalker.get_script(), LoggieEnums.NamelessClassExtensionNameProxy.SCRIPT_NAME)
	c_print("When testing the results of using a modern vs legacy approach to extracting a SCRIPT_NAME proxy, got results:\n\tModern: `{modern}`\n\tLegacy: `{legacy}`".format({
		"modern": script_name_modern,
		"legacy": script_name_legacy,
	}), false, true)
	if script_name_legacy != script_name_modern:
		c_print("❌ They should be identical, but they aren't.", false, true)
		comparison_failure = true
		
	Loggie.class_names.clear()
	var class_name_modern = LoggieTools.get_class_name_from_script(LoggieAutoloadedTalker.get_script(), LoggieEnums.NamelessClassExtensionNameProxy.BASE_TYPE)
	var class_name_legacy = LoggieTools.extract_class_name_from_gd_script(LoggieAutoloadedTalker.get_script(), LoggieEnums.NamelessClassExtensionNameProxy.BASE_TYPE)
	c_print("When testing the results of using a modern vs legacy approach to extracting a BASE_TYPE proxy, got results:\n\tModern: `{modern}`\n\tLegacy: `{legacy}`".format({
		"modern": class_name_modern,
		"legacy": class_name_legacy,
	}), false, true)

	if class_name_legacy != class_name_modern:
		c_print("❌ They should be identical, but they aren't.", false, true)
		comparison_failure = true
		
	if comparison_failure:
		fail()
		return

	success()
	return

func on_msg_received(msg : LoggieMsg, _type : LoggieEnums.MsgType):
	received_msgs.push_back(msg.last_preprocess_result)
