class_name DiscordLoggieMsgChannel extends LoggieMsgChannel

const discord_msg_character_limit = 2000 # The max. amount of characters the content of the message can contain before discord refuses to post it.
var debug_domain = "_d_loggie_discord"
var debug_enabled = false

func _init() -> void:
	self.ID = "discord"
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

	var webhook_url = loggie.settings.discord_webhook_url_live if loggie.is_in_production() else loggie.settings.discord_webhook_url_dev
	if webhook_url == null or (webhook_url is String and webhook_url.is_empty()):
		push_error("Attempt to send a message to the Discord channel with an invalid webhook_url.")
		return

	var output_text = LoggieTools.convert_string_to_format_mode(msg.last_preprocess_result, LoggieEnums.MsgFormatMode.MARKDOWN)

	# Chunk the given string into chunks of maximum supported size by Discord, so we don't end up hitting the character limit
	# which would prevent the message from getting posted.
	var chunks = LoggieTools.chunk_string(output_text, discord_msg_character_limit)
	if chunks.size() > 1:
		loggie.debug("Chunking a long (", output_text.length(), "length ) message while sending to Discord into:", chunks.size(), "chunks.")
	for chunk : String in chunks:
		call_deferred("send_post_request", loggie, chunk, webhook_url)

func send_post_request(logger : Variant, output_text : String, webhook_url : String):
	# Enable debug messages if configured.
	logger.set_domain_enabled(debug_domain, debug_enabled)

	# Create a new HTTPRequest POST request that will be sent to Discord and add it into the scenetree.
	var http = HTTPRequest.new()
	logger.add_child(http)

	# When the request is completed, destroy it.
	http.request_completed.connect(func(result, response_code, headers, body):
		var debug_msg = logger.msg("HTTP Request Completed:").color(Color.ORANGE).header().domain(debug_domain).channel("terminal")
		debug_msg.nl().msg("Result:").color(Color.ORANGE).bold().space().msg(result).nl()
		debug_msg.msg("Response Code:").color(Color.ORANGE).bold().space().msg(response_code).nl()
		debug_msg.msg("Headers:").color(Color.ORANGE).bold().space().msg(headers).nl()
		debug_msg.msg("Body:").color(Color.ORANGE).bold().space().msg(body)
		debug_msg.debug()
		
		## Inform the user about a received non-success response code.
		if response_code < 200 or response_code > 299:
			logger.msg("Discord responded with a non-success code: ").bold().msg(response_code, " - This is an indicator that something about the message you tried to send to Discord does not comply with their request body standards (e.g. content is too long, invalid format, etc.)").channel("terminal").warn()
		
		http.queue_free()
	)
	
	# Convert the [LoggieMsg]'s contents into markdown and post that to the target webhook url.
	var json = JSON.stringify({"content": output_text})
	var header = ["Content-Type: application/json"]

	# Construct debug message.
	if debug_enabled:
		var debug_msg_post = logger.msg("Sending POST Request:").color(Color.CORNFLOWER_BLUE).header().channel("terminal").domain(debug_domain).nl()
		debug_msg_post.msg("JSON stringified (length {size}):".format({"size": output_text.length()})).color(Color.LIGHT_SLATE_GRAY).bold().space().msg(json).color(Color.SLATE_GRAY)
		debug_msg_post.debug()
	
	# Send the request.
	http.request(webhook_url, header, HTTPClient.METHOD_POST, json)
