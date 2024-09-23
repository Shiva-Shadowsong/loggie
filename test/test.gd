extends Control

func _ready() -> void:
	$Label.text = "Loggie {version}".format({"version": Loggie.VERSION})
	test()

func test() -> void:
	
	# Test outputting a box header.
	Loggie.msg("Box Header Test").color("red").box().info()
	
	# Test outputting a header, with a newline and a 30 character long horizontal separator.
	Loggie.msg("Header").header().nl().hseparator(30).info()

	# Test all types of messages.
	Loggie.msg("Hello World").info()
	Loggie.msg("Hello", "World", "Multi", "Argument").info()
	Loggie.msg("Test error.").error()
	Loggie.msg("Test warning.").warn()
	Loggie.msg("Test notice.").notice()
	Loggie.msg("Test debug message.").debug()
	
	# Test a supported color message.
	Loggie.msg("I'm cyan.").color(Color.CYAN).info()
	
	# Test a custom colored message.
	Loggie.msg("I'm slate blue.").color(Color.SLATE_BLUE).info()
	
	# Test pretty printing a dictionary.
	var testDict = {
		"a" : "Hello",
		"b" : {
			"c" : 1,
			"d" : [1,2,3]
		},
		"c" : ["A", {"B" : "2"}, 3]
	}
	Loggie.msg(testDict).info()
	
	# Test outputting a message from an enabled custom domain.
	Loggie.set_domain_enabled("Domain1", true)
	Loggie.msg("This message is coming from an enabled domain.").domain("Domain1").info()

	# Test outputting a message from a disabled domain.
	Loggie.set_domain_enabled("Domain1", false)
	Loggie.msg("This message is coming from a disabled domain (you shouldn't be seeing this in the output).").domain("Domain1").info()

	# Test outputting a message from a different script.
	# If 'Loggie.settings.derive_and_show_class_names' is true, the name of the class should show up properly as prefix.
	var talker = LoggieTalker.new()
	talker.say("Greetings!")
	
