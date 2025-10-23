class_name VisualTestsMenuEntry extends HBoxContainer

var _case : LoggieVisualTestCase

func _ready() -> void:
	%Checkbox.disabled = true
	%Checkbox.button_pressed = false

func connect_to_test_case(case : LoggieVisualTestCase):
	_case = case
	_case.state_changed.connect(on_case_state_changed)
	
	if _case.title != "":
		%Button.text = _case.title
	else:
		%Button.text = _case.get_script().get_global_name()

func on_case_state_changed(state : LoggieVisualTestCase.State):
	if state == LoggieVisualTestCase.State.Rejected:
		%Checkbox.button_pressed = true
		%Button.disabled = true
		%Button.add_theme_color_override("font_color", Color.SALMON)
		%Button.add_theme_color_override("font_disabled_color", Color.SALMON)
	if state == LoggieVisualTestCase.State.Accepted:
		%Checkbox.button_pressed = true
		%Button.disabled = true
		%Button.add_theme_color_override("font_color", Color.PALE_GREEN)
		%Button.add_theme_color_override("font_disabled_color", Color.PALE_GREEN)
	if state == LoggieVisualTestCase.State.Undecided:
		%Checkbox.button_pressed = false
		%Button.disabled = false
		%Button.add_theme_color_override("font_color", Color.WHITE)
		%Button.add_theme_color_override("font_disabled_color", "#dfdfdf80")

func get_button() -> Button:
	return %Button

func get_checkbox() -> CheckBox:
	return %Checkbox
