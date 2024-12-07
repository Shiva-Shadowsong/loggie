class_name DiscordLoggieMsgChannel extends LoggieMsgChannel

func _init() -> void:
	self.ID = "discord"
	self.preprocess_flags = 0 # For this type of channel, this will be applied dynamically by Loggie after it loads LoggieSettings.

func send(msg : LoggieMsg, msg_type : LoggieEnums.MsgType):
	var http = HTTPRequest.new()
	msg.get_logger().add_child(http)

	http.request_completed.connect(func(result, response_code, headers, body):
		#var json = JSON.parse_string(body.get_string_from_utf8())
		#print(json["number"])
		
		var loggie = Loggie.msg().channel("discord")
		http.queue_free()
	)
	
	var plainMessage = LoggieTools.get_terminal_ready_string(msg.last_preprocess_result, LoggieEnums.TerminalMode.PLAIN)
	
	var json = JSON.stringify({"content": plainMessage})
	var header = ["Content-Type: application/json"]
	http.request(msg.get_logger().settings.discord_webhook_url, header, HTTPClient.METHOD_POST, json)	
