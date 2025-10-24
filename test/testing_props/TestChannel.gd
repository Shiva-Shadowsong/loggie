@tool
class_name LoggieTestChannel extends LoggieMsgChannel

signal message_received(msg : LoggieMsg, type : LoggieEnums.MsgType)

func _init() -> void:
	ID = "test_channel" # same as file name
	preprocess_flags = LoggieEnums.PreprocessStep.APPEND_TIMESTAMPS | LoggieEnums.PreprocessStep.APPEND_DOMAIN_NAME | LoggieEnums.PreprocessStep.APPEND_CLASS_NAME
	
func send(msg : LoggieMsg, type : LoggieEnums.MsgType):
	message_received.emit(msg, type)
