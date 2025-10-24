## Tests whether:
##[br]* The [method LoggieMsg.no_signal] method and its related functionality works properly.
class_name TestNoSignal extends LoggieAutoTestCase

var received_msgs = []
	
func run() -> void:
	settings.log_level = LoggieEnums.LogLevel.DEBUG
	settings.default_channels = ["test_channel"]
	Loggie.log_attempted.connect(on_log_attempted)
	
	## Should send a log_attempted signal that we can catch.
	Loggie.msg("0").debug()
	
	## Should not send a log_attempted signal.
	Loggie.msg("1").no_signal().debug()
	
	## Should send a log_attempted signal that we can catch.
	settings.log_level = LoggieEnums.LogLevel.ERROR
	Loggie.msg("2").debug()
	
	## Should not send a log_attempted signal.
	Loggie.msg("3").no_signal().debug()
	
	# Await 2 frames for Loggie's internal deferred calls to go through.
	await get_tree().process_frame
	await get_tree().process_frame
	
	var failed_checks = false
	if not(received_msgs.size() == 2 and received_msgs.has("0") and received_msgs.has("2")):
		c_print("❌ Caught different messages than expected. Expected exactly 2 values (in any order): [\"0\", \"2\"], got: {received_msgs}".format({"received_msgs": received_msgs}))
		failed_checks = true

	Loggie.log_attempted.disconnect(on_log_attempted)
	
	if failed_checks:
		fail()
		return

	success()
	return

func on_log_attempted(_msg : LoggieMsg, msg_string : String, _result : LoggieEnums.LogAttemptResult) -> void:
	received_msgs.push_back(msg_string)
