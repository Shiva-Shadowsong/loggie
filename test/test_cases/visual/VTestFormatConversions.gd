class_name VTestFormatConversions extends LoggieVisualTestCase

func _init() -> void:
	title = "Format Conversions"

func run() -> void:
	var test_console_channel : LoggieTestConsoleChannel = Loggie.get_channel("test_console")
	test_console_channel.preprocess_flags = 0
	var msg = Loggie.msg("Hello from ").bold().italic().msg("Loggie").color("orange")

	_console.add_text("The message [color=cornflower_blue][b]msg('Hello from').bold().italic().msg('Loggie').color('orange')[/b][/color] will be printed below, 
	4 times, once for each supported message format. You should visually verify that it looks good and appropriate for each format.")
	_console.add_content(HSeparator.new())
	
	_console.add_text("[color=cornflower_blue][b][i]BBCode[/i][/b][/color]")
	_console.add_text("[color=gray]You should see the full style in action here.[/color]\n\n")
	Loggie.settings.msg_format_mode = LoggieEnums.MsgFormatMode.BBCODE
	msg.channel("test_console").info()
	_console.add_content(HSeparator.new())
	
	_console.add_text("[color=cornflower_blue][b][i]ANSI[/i][/b][/color]")
	_console.add_text("[color=gray]Should be tested in some external terminal that renders ANSI sequences fully.[/color]\n\n")
	Loggie.settings.msg_format_mode = LoggieEnums.MsgFormatMode.ANSI
	var lineedit = LineEdit.new()
	lineedit.select_all_on_focus = true
	lineedit.editable = false
	lineedit.text = LoggieTools.convert_string_to_format_mode(msg.last_preprocess_result, LoggieEnums.MsgFormatMode.ANSI)
	_console.add_content(lineedit)
	_console.add_content(HSeparator.new())
	
	_console.add_text("[color=cornflower_blue][b][i]MARKDOWN[/i][/b][/color]")
	_console.add_text("[color=gray]Markdown does not support colors. Therefore, the color tag should be gone, but bold and italic should still apply.[/color]\n\n")
	Loggie.settings.msg_format_mode = LoggieEnums.MsgFormatMode.MARKDOWN
	var lineedit2 = LineEdit.new()
	lineedit2.select_all_on_focus = true
	lineedit2.editable = false
	lineedit2.text = LoggieTools.convert_string_to_format_mode(msg.last_preprocess_result, LoggieEnums.MsgFormatMode.MARKDOWN)
	_console.add_content(lineedit2)
	_console.add_content(HSeparator.new())
	
	_console.add_text("[color=cornflower_blue][b][i]PLAIN[/i][/b][/color]")
	_console.add_text("[color=gray]The message below should have no styling or BBCode tags whatsoever.[/color]\n\n")
	Loggie.settings.msg_format_mode = LoggieEnums.MsgFormatMode.PLAIN
	Loggie.msg("Hello from ").bold().italic().msg("Loggie").color("orange").channel('test_console').info()
	_console.add_content(HSeparator.new())
