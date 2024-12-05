class_name DiscordLoggieMsgChannel extends LoggieMsgChannel

func _init() -> void:
	self.ID = "discord"
	self.preprocess_flags = 0 # For this type of channel, this will be applied dynamically by Loggie after it loads LoggieSettings.

func send(msg : LoggieMsg, msg_type : LoggieEnums.MsgType):
	pass
