class_name VTestStackPrinting extends LoggieVisualTestCase

func _init() -> void:
	title = "Stack"

func run() -> void:
	var test_console_channel : LoggieTestConsoleChannel = Loggie.get_channel("test_console")
	test_console_channel.preprocess_flags = 0

	_console.add_text("Please verify that below, there are two 'Hello World' messages. The first one, with a properly stylized and accurate stack trace - and the second one without any stack trace.")
	_console.add_content(HSeparator.new())
	var msg = Loggie.msg("Hello world!").channel("test_console").stack(true)
	msg.info()
	_console.add_content(HSeparator.new())
	msg.stack(false)
	msg.info()
