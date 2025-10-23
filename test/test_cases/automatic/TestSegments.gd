## Tests whether:
##[br]* Segmenting a message works and keeps the segments separated.
##[br]* Segments can be styled on an individual basis.
class_name TestSegments extends LoggieAutoTestCase

var received_msgs = []
	
func run() -> void:
	settings.log_level = LoggieEnums.LogLevel.DEBUG
	settings.default_channels = ["test_channel"]
	
	var msg1 = Loggie.msg("seg1").msg("seg2").msg("seg3") # Should be 3 separated segments.
	
	if not(msg1.content.size() == 3 and msg1.content.has("seg1") and msg1.content.has("seg2") and msg1.content.has("seg3")):
		c_print("❌ Message structure is not as expected. Expected 3 content segments: [\"seg1\",\"seg2\",\"seg3\"], got: {content}".format({
			"content": msg1.content
		}))
		fail()
		return
		
	
	var msg2 = Loggie.msg("seg1").add("seg2").add("seg3") # Should all be 1 segment.
	if not (msg2.string() == "seg1seg2seg3"):
		c_print("❌ Message structure is not as expected. Expected \"seg1seg2seg3\", got: {msg}".format({
			"msg": msg2.string()
		}))
		fail()
		return
	
	
	var msg3 = Loggie.msg("key: ").color("orange").bold().endseg().add("value") # Should be [b][color="orange"]key: [/color][/b]value
	
	var expected_output = "[b][color=orange]key: [/color][/b]value"
	if msg3.string() != expected_output:
		c_print("❌ Message structure is not as expected. Expected `{expected}`, got: `{msg}`".format({
			"msg": msg3.string(),
			"expected": expected_output
		}))
		fail()
		return

	success()
	return
