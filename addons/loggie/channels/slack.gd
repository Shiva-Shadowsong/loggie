class_name SlackLoggieMsgChannel extends LoggieMsgChannel

var debug_domain = "_d_loggie_slack"
var debug_enabled = false

func _init() -> void:
	self.ID = "slack"
	self.preprocess_flags = 0 # For this type of channel, this will be applied dynamically by Loggie after it loads LoggieSettings.

func send(msg : LoggieMsg, msg_type : LoggieEnums.MsgType):
	# Validate variables.
	var loggie = msg.get_logger()
	if loggie == null:
		push_error("Attempt to send a message that's coming from an invalid logger.")
		return
	
	# Wait until loggie is inside tree so that we can use add_child(http) on it without errors.
	if !loggie.is_inside_tree():
		loggie.tree_entered.connect(func():
			send(msg, msg_type)
		, CONNECT_ONE_SHOT)
		return
		
	var webhook = loggie.settings.slack_webhook_url_live if loggie.is_in_production() else loggie.settings.slack_webhook_url_dev
	if webhook == null or (webhook is String and webhook.is_empty()):
		push_error("Attempt to send a message to the Slack channel with an invalid webhook.")
		return

	# Enable debug messages if configured.
	loggie.set_domain_enabled(debug_domain, debug_enabled)

	# Create a new HTTPRequest POST request that will be sent to Slack and add it into the scenetree.
	var http = HTTPRequest.new()
	loggie.add_child(http)

	# When the request is completed, destroy it.
	http.request_completed.connect(func(result, response_code, headers, body):
		var debug_msg = loggie.msg("HTTP Request Completed:").color(Color.ORANGE).header().domain(debug_domain)
		debug_msg.nl().msg("Result:").color(Color.ORANGE).bold().space().msg(result).nl()
		debug_msg.msg("Response Code:").color(Color.ORANGE).bold().space().msg(response_code).nl()
		debug_msg.msg("Headers:").color(Color.ORANGE).bold().space().msg(headers).nl()
		debug_msg.msg("Body:").color(Color.ORANGE).bold().space().msg(body)
		debug_msg.debug()

		## Inform the user about a received non-success response code.
		if response_code < 200 or response_code > 299:
			loggie.msg("Slack responded with a non-success code: ").bold().msg(response_code, " - This is an indicator that something about the message you tried to send to Slack does not comply with their request body standards (e.g. content is too long, invalid format, etc.)").channel("terminal").warn()
	
		http.queue_free()
	)
	
	# Convert the [LoggieMsg]'s contents into markdown and post that to the target webhook url.
	var md_text = LoggieTools.convert_string_to_format_mode(msg.last_preprocess_result, LoggieEnums.MsgFormatMode.PLAIN)
	var json = JSON.stringify({"text": md_text})
	var header = ["Content-Type: application/json"]
	
	# Construct debug message.
	if debug_enabled:
		var debug_msg_post = loggie.msg("Sending POST Request:").color(Color.ORANGE).header().domain(debug_domain).nl()
		debug_msg_post.msg("Preprocessed message:").color(Color.ORANGE).bold().space().msg(msg.last_preprocess_result).nl()
		debug_msg_post.msg("JSON stringified:").color(Color.ORANGE).bold().space().msg(json)
		debug_msg_post.debug()
	
	# Send the request.
	http.request(webhook, header, HTTPClient.METHOD_POST, json)
