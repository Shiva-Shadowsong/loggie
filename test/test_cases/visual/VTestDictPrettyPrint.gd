class_name VTestDictPrettyPrint extends LoggieVisualTestCase

func _init() -> void:
	title = "Pretty Dictionaries"

func run() -> void:
	_console.add_text("Please verify that below, there are exactly 2 messages, both displaying the same dictionary. The first one should be displaying it in the original Godot format, the second one should be 'prettified' (verify that the indenting and spacing looks correct):")
	var hsep = HSeparator.new()
	_console.add_content(hsep)
	send_test_messages()

func send_test_messages() -> void:
	var testDict = {
		"name": "testDict",
		"ownedItemIDs": [1,2,3],
		"stats": {
			"HP": 5.50,
			"MP": 1,
			"nestedStat" : {
				"STR": 1,
				"AGI": 5
			}
		} 
	}
	
	Loggie.msg(str(testDict)).channel("test_console").info()
	Loggie.msg(testDict).channel("test_console").info()
