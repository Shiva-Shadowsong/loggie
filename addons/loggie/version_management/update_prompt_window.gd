@tool
## The Loggie Update Prompt is a control node that is meant to be created and added as a child of some other node, most commonly a [Window].
## It connects to a [LoggieUpdate] via its [method connect_to_update] method, then displays data about that update depending on what kind of
## data that [LoggieUpdate] provides with its signals.
class_name LoggieUpdatePrompt extends Panel

## Emitted when the user requests to close the update prompt.
signal close_requested()

## The animation player that will be used to animate the appearance of this window.
@export var animator : AnimationPlayer

## The size the window that's hosting this panel will be forced to assume when
## it's ready to pop this up on the screen.
@export var host_window_size : Vector2 = Vector2(1063, 672)

## Stores a reference to the logger that's using this window.
var _logger : Variant

## The update this window is visually representing.
var _update : LoggieUpdate

## Stores a boolean which indicates whether the update is currently in progress.
var is_currently_updating : bool = false

func _ready() -> void:
	connect_control_effects()
	%UpdateNowBtn.grab_focus()
	refresh_remind_later_btn()
	animator.play("RESET")

## Connects this window to an instance of [LoggieUpdate] whose progress and properties this window is supposed to track.
func connect_to_update(p_update : LoggieUpdate) -> void:
	self._update = p_update
	_update.is_in_progress_changed.connect(is_update_in_progress_changed)
	_update.starting.connect(on_update_starting)
	_update.succeeded.connect(on_update_succeeded)
	_update.failed.connect(on_update_failed)
	_update.progress.connect(on_update_progress)
	_update.status_changed.connect(on_update_status_changed)

## Returns a reference to the logger object that is using this widget.
func get_logger() -> Variant:
	return self._logger
	
## Defines what happens when the update this window is representing updates its "is in progress" status.
func is_update_in_progress_changed(is_in_progress : bool) -> void:
	self.is_currently_updating = is_in_progress
	
	# The first time we enter the UpdateMonitor view and start an update,
	# the %Notice node and its children should no longer (ever) be interactive or processing,
	# since there is no way to get back to that view anymore.
	if is_in_progress and %Notice.process_mode != Node.PROCESS_MODE_DISABLED:
		%Notice.process_mode = Node.PROCESS_MODE_DISABLED
		for child in %NoticeButtons.get_children():
			if child is Button:
				child.focus_mode = Button.FOCUS_NONE
	
## Connects the effects and functionalities of various controls in this window.
func connect_control_effects():
	if !is_instance_valid(self._update):
		return

	# Configure version(s) labels.
	%LabelCurrentVersion.text = str(self._update.prev_version)
	%LabelLatestVersion.text = str(self._update.new_version)
	%LabelOldVersion.text = str(self._update.prev_version)
	%LabelNewVersion.text = str(self._update.new_version)
	
	# Configure onhover/focused effects.
	var buttons_with_on_focushover_effect = [%OptionExitBtn, %OptionRestartGodotBtn, %OptionRetryUpdateBtn, %ReleaseNotesBtn, %RemindLaterBtn, %UpdateNowBtn]
	for button : Button in buttons_with_on_focushover_effect:
		button.focus_entered.connect(_on_button_focus_entered.bind(button))
		button.focus_exited.connect(_on_button_focus_exited.bind(button))
		button.mouse_entered.connect(_on_button_focus_entered.bind(button))
		button.mouse_exited.connect(_on_button_focus_exited.bind(button))
		button.pivot_offset = button.size * 0.5
		
	# Connect behavior which executes when "Update Now" is pressed.
	%UpdateNowBtn.pressed.connect(func():
		self._update.try_start()
	)
	
	# Configure Release Notes button.
	%ReleaseNotesBtn.visible = !self._update.release_notes_url.is_empty()
	%ReleaseNotesBtn.tooltip_text = "Opens {url} in browser.".format({"url": self._update.release_notes_url})
	%ReleaseNotesBtn.pressed.connect(func():
		if !self._update.release_notes_url.is_empty():
			OS.shell_open(self._update.release_notes_url)
	)
	
	# Connect behavior which executes when the "Remind Me Later / Close" is pressed.
	%RemindLaterBtn.pressed.connect(func(): close_requested.emit())
	%OptionExitBtn.pressed.connect(func(): close_requested.emit())
	
	# Connect behavior which executes when the "Retry" button is pressed.
	%OptionRetryUpdateBtn.pressed.connect(self._update.try_start)
	
	# Connect behavior which executes when the "Restart Godot" button is pressed.
	%OptionRestartGodotBtn.pressed.connect(func():
		close_requested.emit()
		if Engine.is_editor_hint():
			var editor_plugin = Engine.get_meta("LoggieEditorPlugin")
			editor_plugin.get_editor_interface().restart_editor(true)
	)

	# The "Don't show again checkbox" updates project settings whenever it is toggled.
	%DontShowAgainCheckbox.toggled.connect(func(toggled_on : bool):
		var loggie = self.get_logger()
		if Engine.is_editor_hint() and loggie != null:
			if toggled_on:
				loggie.settings.update_check_mode = LoggieEnums.UpdateCheckType.CHECK_AND_SHOW_MSG
				ProjectSettings.set_setting(loggie.settings.project_settings.update_check_mode.path, LoggieEnums.UpdateCheckType.CHECK_AND_SHOW_MSG)
			else:
				loggie.settings.update_check_mode = LoggieEnums.UpdateCheckType.CHECK_AND_SHOW_UPDATER_WINDOW
				ProjectSettings.set_setting(loggie.settings.project_settings.update_check_mode.path, LoggieEnums.UpdateCheckType.CHECK_AND_SHOW_UPDATER_WINDOW)
		refresh_remind_later_btn()
	)

## Updates the content of the "Remind Later Btn" to show text appropriate to the current state of the "Don't show again" checkbox.
func refresh_remind_later_btn():
	if %DontShowAgainCheckbox.button_pressed:
		%RemindLaterBtn.text = "close"
	else:
		%RemindLaterBtn.text = "remind later"

## Defines what happens when the [member _update] is detected to be starting.
func on_update_starting():
	if animator.current_animation != "show_update_overview":
		animator.queue("show_update_overview")
	%ProgressBar.value = 0
	%LabelMainStatus.text = "Downloading"
	%LabelUpdateStatus.text = "Waiting for server response."
	%OptionExitBtn.disabled = true
	%OptionExitBtn.visible = false
	%OptionRetryUpdateBtn.disabled = true
	%OptionRetryUpdateBtn.visible = false
	%OptionRestartGodotBtn.disabled = true
	%OptionRestartGodotBtn.visible = false

## Defines what happens when the [member _update] declares it has made progress.
func on_update_progress(value : float):
	%ProgressBar.value = value

## Defines what happens when the [member _update] declares it has succeeded.
func on_update_succeeded():
	%LabelMainStatus.text = "Updated"
	%OptionExitBtn.disabled = false
	%OptionExitBtn.visible = true
	%OptionRestartGodotBtn.disabled = false
	%OptionRestartGodotBtn.visible = true
	if animator.is_playing():
		animator.stop()
	animator.play("finish_success")

## Defines what happens when the [member _update] declares it wants the status message to change.
func on_update_status_changed(status_msg : Variant, substatus_msg : Variant):
	if status_msg is String:
		%LabelMainStatus.text = status_msg
	if substatus_msg is String:
		%LabelUpdateStatus.text = substatus_msg

## Defines what happens when the [member _update] declares it has failed.
func on_update_failed():
	%ProgressBar.value = 0
	%LabelMainStatus.text = "Failed"
	%OptionExitBtn.disabled = false
	%OptionExitBtn.visible = true
	%OptionRetryUpdateBtn.disabled = false
	%OptionRetryUpdateBtn.visible = true
	%OptionRestartGodotBtn.disabled = true
	%OptionRestartGodotBtn.visible = false

func _on_button_focus_entered(button : Button):
	if button.has_meta("scale_tween"):
		var old_tween = button.get_meta("scale_tween")
		old_tween.kill()
		button.set_meta("scale_tween", null)

	var tween : Tween = button.create_tween()
	tween.tween_property(button, "scale", Vector2(1.2, 1.2), 0.1)
	button.set_meta("scale_tween", tween)

func _on_button_focus_exited(button : Button):
	if button.has_meta("scale_tween"):
		var old_tween = button.get_meta("scale_tween")
		old_tween.kill()
		button.set_meta("scale_tween", null)

	var tween : Tween = button.create_tween()
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.1).from_current()
	button.set_meta("scale_tween", tween)
