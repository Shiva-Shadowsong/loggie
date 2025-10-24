class_name LoggieTestConsole extends Panel

func _ready() -> void:
	%AcceptBtn.pressed.connect(on_accept_pressed)
	%RejectBtn.pressed.connect(on_decline_pressed)

func run_tests() -> void:
	pass

func add_content(node : Node) -> Node:
	%Content.add_child(node)
	return node

func add_text(txt : String) -> RichTextLabel:
	var label = RichTextLabel.new()
	label.fit_content = true
	label.bbcode_enabled = true
	label.text = txt
	%Content.add_child(label)
	return label

func fade_out_prev_content() -> void:
	pass

func on_decline_pressed() -> void:
	pass

func on_accept_pressed() -> void: 
	pass
