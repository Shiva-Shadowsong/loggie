## Tests whether:
## [br]* Disabling timestamps results in a message without timestamp.
## [br]* Enabling timestamps (with UTC) results in a message with a UTC timestamp.
## [br]* Enabling timestamps (no UTC) results in a message with a non-UTC timestamp.
class_name TestFormatting_Timestamps extends LoggieAutoTestCase

var msg_text = "test"

func run() -> void:
	settings.log_level = LoggieEnums.LogLevel.DEBUG
	settings.default_channels = ["test_channel"]
	settings.format_info_msg = "{msg}"
	var test_channel : LoggieMsgChannel = Loggie.get_channel("test_channel")
	var succesful_messages = []
	var test_msg = Loggie.msg(msg_text).preprocessed(true)

	var on_msg_received_substep : Callable = func(msg : LoggieMsg, _type : LoggieEnums.MsgType, expected_output : String):
		print_objective(msg.last_preprocess_result, expected_output)
		if msg.last_preprocess_result == expected_output:
			succesful_messages.push_back(msg)
			
	test_channel.message_received.connect(on_msg_received_substep.bind(msg_text))

	# ----------- Substep 1: Test when timestamps are disabled. ------------ #
	print_rich("\t Testing that there will be no timestamp if timestamp preprocess step is disabled.")
	test_channel.preprocess_flags = 0
	test_msg.info()
	await get_tree().process_frame; await get_tree().process_frame
	test_channel.message_received.disconnect(on_msg_received_substep)
	
	# ----------- Substep 2: Test when timestamps are enabled (no UTC). ------------ #
	print_rich("\t Testing that there will be a UTC timestamp when timestamps preprocess step is enabled and timestamps_use_utc = true.")
	settings.timestamps_use_utc = true
	test_channel.preprocess_flags = LoggieEnums.PreprocessStep.APPEND_TIMESTAMPS
	test_channel.message_received.connect(on_msg_received_substep.bind(Loggie.msg()._apply_format_timestamp(msg_text)))
	test_msg.info()
	await get_tree().process_frame; await get_tree().process_frame
	test_channel.message_received.disconnect(on_msg_received_substep)
	
	# ----------- Substep 3: Test when timestamps are enabled (UTC). ------------ #
	# Reuse substep2 callback since the same code will work, just needed to set settings.timestamps_use_utc to false in this case.
	print_rich("\t Testing that there will be a non-UTC timestamp when timestamps preprocess step is enabled and timestamps_use_utc = false.")
	settings.timestamps_use_utc = false
	test_channel.message_received.connect(on_msg_received_substep.bind(Loggie.msg()._apply_format_timestamp(msg_text)))
	test_msg.info()
	await get_tree().process_frame; await get_tree().process_frame
	test_channel.message_received.disconnect(on_msg_received_substep)

	# Everything was fine if all 3 substeps succeeded.
	if succesful_messages.size() < 3:
		fail()
		return

	success()
	return

func print_objective(compared_value : String, expected_value : String) -> void:
	var outputtxt = "\t\t\tTop (received value) matches bottom (expected value)?\n\t\t\t\t'{msg}'\n\t\t\t\t'{expected}'\n\t\t\tResult:".format({
		"msg": compared_value,
		"expected": expected_value
	})
	if compared_value == expected_value:
		outputtxt += " ✔️"
	else:
		outputtxt += " ❌"
	print(outputtxt)
