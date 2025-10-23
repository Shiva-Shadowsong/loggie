## Tests whether:
##[br]* The [method LoggieMsg.link] method creates a properly wrapped URL.
class_name TestLinks extends LoggieAutoTestCase

var received_msgs = []
	
func run() -> void:
	var url = "https://godotengine.org/"
	var pretext = "Visit the Godot Engine website "
	var urltxt = "here"

	var msg = Loggie.msg(pretext).msg(urltxt).link(url).info()
	var expected_msg = "{pretext}[url={url}]{urltext}[/url]".format({"pretext": pretext, "url": url, "urltext": urltxt})
	
	if expected_msg != msg.string():
		c_print("❌ The message with the URL modifier ended up looking different than expected.\nExpected: {expected}\nReceived: {received}".format({
			"expected": expected_msg,
			"received": msg.string()
		}))
		fail()
		return

	msg = Loggie.msg(pretext).msg(urltxt).link(url, "blue").info()
	expected_msg = "{pretext}[color=blue][url={url}]{urltext}[/url][/color]".format({"pretext": pretext, "url": url, "urltext": urltxt})
	
	if expected_msg != msg.string():
		c_print("❌ The message with the colored URL modifier ended up looking different than expected.\nExpected: {expected}\nReceived: {received}".format({
			"expected": expected_msg,
			"received": msg.string()
		}))
		fail()
		return

	success()
	return
