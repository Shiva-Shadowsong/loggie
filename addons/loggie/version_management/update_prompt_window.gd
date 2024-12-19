@tool
class_name LoggieUpdatePrompt extends Panel

## Emitted when the user requests to close the update prompt.
signal close_requested()

## The path to the directory that should have a temporary file created and filled with the patch zipball buffer.
const TEMP_FILES_DIR = "user://"

## The path where the current version of Loggie can be found, which will also be the target directory
## to populate when applying the patch.
const LOGGIE_PLUGIN_DIR = "user://current_loggie_dir/"

## The animation player that will be used to animate the appearance of this window.
@export var animator : AnimationPlayer

## The size the window that's hosting this panel will be forced to assume when
## it's ready to pop this up on the screen.
@export var host_window_size : Vector2 = Vector2(1063, 672)

## Stores a reference to the logger that's using this window.
var _logger : Variant

## If set to a non-empty string, the "Release Notes" button will appear and 
## prompt Godot to open this string as an URL when clicked.
var release_notes_url = ""

## Stores a reference to the previous version of Loggie.
var prev_version : LoggieVersionManager.LoggieVersion = null

## Stores a reference to the new version of Loggie.
var new_version : LoggieVersionManager.LoggieVersion = null

## Stores a boolean which indicates whether the update is currently in progress.
var is_currently_updating : bool = false


func _ready() -> void:
	connect_control_effects()
	configure_for_versions(self._logger.version_manager.version, self._logger.version_manager.latest_version)
	%UpdateNowBtn.grab_focus()
	refresh_remind_later_btn()
	animator.play("RESET")

## Returns a reference to the logger object that is using this widget.
func get_logger() -> Variant:
	return self._logger
	
## Sets the URL which will be visited when the user presses the Release Notes button.
func set_release_notes_url(url : String) -> void:
	self.release_notes_url = url
	%ReleaseNotesBtn.visible = !url.is_empty()
	%ReleaseNotesBtn.tooltip_text = "Opens {url} in browser.".format({"url": url})
	
## Connects the effects and functionalities of various controls in this window.
func connect_control_effects():
	# Configure onhover/focused effects.
	var buttons_with_on_focushover_effect = [%ReleaseNotesBtn, %RemindLaterBtn, %UpdateNowBtn]
	for button : Button in buttons_with_on_focushover_effect:
		button.focus_entered.connect(_on_button_focus_entered.bind(button))
		button.focus_exited.connect(_on_button_focus_exited.bind(button))
		button.mouse_entered.connect(_on_button_focus_entered.bind(button))
		button.mouse_exited.connect(_on_button_focus_exited.bind(button))
		button.pivot_offset = button.size * 0.5
		
	# Connect behavior which executes when "Update Now" is pressed.
	%UpdateNowBtn.pressed.connect(func():
		try_start_update()
	)
	
	# Connect behavior which executes when "Release Notes" is pressed.
	%ReleaseNotesBtn.pressed.connect(func():
		if !self.release_notes_url.is_empty():
			OS.shell_open(release_notes_url)
	)
	
	# Connect behavior which executes when the "Remind Me Later / Close" is pressed.
	%RemindLaterBtn.pressed.connect(func(): close_requested.emit())
	%OptionExitBtn.pressed.connect(func(): close_requested.emit())
	
	# Connect behavior which executes when the "Retry" button is pressed.
	%OptionRetryUpdateBtn.pressed.connect(try_start_update)

	# The "Don't show again checkbox" updates project settings whenever it is toggled.
	%DontShowAgainCheckbox.toggled.connect(func(toggled_on : bool):
		var loggie = self.get_logger()
		if Engine.is_editor_hint() and loggie != null:
			if toggled_on:
				loggie.settings.update_check_mode = LoggieEnums.UpdateCheckType.DONT_CHECK
				ProjectSettings.set_setting(loggie.settings.project_settings.update_check_mode.path, LoggieEnums.UpdateCheckType.DONT_CHECK)
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

## Configures which versions this updater considers the previous existing version, and the new available version (respectively).
func configure_for_versions(p_prev_version : LoggieVersionManager.LoggieVersion, p_new_version : LoggieVersionManager.LoggieVersion):
	self.prev_version = p_prev_version
	self.new_version = p_new_version
	%LabelCurrentVersion.text = str(self.prev_version)
	%LabelLatestVersion.text = str(self.new_version)

## Tries to start the version update. Prevents the update from starting
## if something is not configured correctly and pushes a warning/error.
func try_start_update():
	if self.is_currently_updating:
		return

	if self.new_version == null or self.prev_version == null:
		push_warning("Attempt to start Loggie update failed - the updater prompt has the 'new_version' or 'prev_version' variable at null value.")
		return
	elif !self.new_version.is_higher_than(self.prev_version):
		push_warning("Attempt to start Loggie update failed - the 'new_version' is not higher than 'prev_version'.")
		return

	if self.new_version.has_meta("github_data"):
		var github_data = self.new_version.get_meta("github_data")
		if !github_data.has("zipball_url"):
			push_error("Attempt to start Loggie update failed - the meta key 'github_data' on the 'new_version' is a dictionary that does not contain the required 'zipball_url' key/value pair.")
			return
	else:
		push_error("Attempt to start Loggie update failed - the meta key 'github_data' on the 'new_version' was not found.")
		return
	
	_start_update()
	
## Internal function. Starts the updating of Loggie to the [param new_version].
## Do not run without verification that configuration is correct.
## Use [method try_start_update] instead.
func _start_update():
	self.is_currently_updating = true
	var update_data = self.new_version.get_meta("github_data")

	# Make request to configured endpoint.
	animator.queue("show_update_overview")
	var http_request = HTTPRequest.new()
	self.add_child(http_request)
	http_request.request_completed.connect(_on_download_request_completed)
	http_request.request(update_data.zipball_url)
	
	# Reset UI to initial state.
	%ProgressBar.value = 0
	%UpdateNowBtn.disabled = true
	%LabelMainStatus.text = "Downloading"
	%LabelUpdateStatus.text = "Waiting for server response."
	%OptionExitBtn.disabled = true
	%OptionRetryUpdateBtn.disabled = true
	%OptionExitBtn.visible = false
	%OptionRetryUpdateBtn.visible = false

## Internal callback function. 
## Defines what happens when new update content is successfully downloaded from GitHUb.
## Called automatically during [method _start_update] if everything is going according to plan.
func _on_download_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var loggie = self.get_logger()

	if loggie == null:
		_fail_update("The _logger used by the updater window is null.")
		return

	if result != HTTPRequest.RESULT_SUCCESS:
		_fail_update("Download request returned non-zero code: " + str(result))
		return
	
	# -------------------------
	# Store the downloaded content into a temporary file.
	%ProgressBar.value = 20
	%LabelMainStatus.text = "Processing Files"
	%LabelUpdateStatus.text = "Storing patch locally."
	var TEMP_ZIP_FILE_PATH = TEMP_FILES_DIR.path_join("temp_loggie_update_archive.zip")
	var zip_file: FileAccess = FileAccess.open(TEMP_ZIP_FILE_PATH, FileAccess.WRITE)
	if zip_file == null:
		_fail_update("Failed to open temp. file for writing: {path}".format({"path": TEMP_ZIP_FILE_PATH}))
		return
	zip_file.store_buffer(body)
	zip_file.close()

	# -------------------------
	# Make a temporary backup of the current Loggie plugin files.
	%ProgressBar.value = 30
	%LabelUpdateStatus.text = "Backing up previous version files..."
	
	if !DirAccess.dir_exists_absolute(LOGGIE_PLUGIN_DIR):
		_fail_update("The Loggie plugin directory ({path}) could not be found.".format({
			"path" : ProjectSettings.globalize_path(LOGGIE_PLUGIN_DIR)
		}))
		return

	#var path_to_delete = loggie.get_directory_path() # TODO
	var TEMP_PREV_VER_FILES_DIR_PATH = ProjectSettings.globalize_path(TEMP_FILES_DIR.path_join("_temp_loggie_backup"))
	var copy_prev_ver_result = LoggieTools.copy_dir_absolute(LOGGIE_PLUGIN_DIR, TEMP_PREV_VER_FILES_DIR_PATH, true)

	# A callable that can be reused within this function that cleans up the temporary and unused directories,
	# once this function comes to a conclusion.
	var clean_up : Callable = func():
		if DirAccess.dir_exists_absolute(TEMP_ZIP_FILE_PATH):
			DirAccess.remove_absolute(TEMP_ZIP_FILE_PATH)
		if DirAccess.dir_exists_absolute(TEMP_PREV_VER_FILES_DIR_PATH):
			DirAccess.remove_absolute(TEMP_PREV_VER_FILES_DIR_PATH)
	
	if copy_prev_ver_result.errors.size() > 0:
		var copy_prev_var_result_errors_msg = LoggieMsg.new("Errors encountered:")
		for error in copy_prev_ver_result.errors:
			copy_prev_var_result_errors_msg.nl().add(error_string(error))
		_fail_update(copy_prev_var_result_errors_msg.string())
		clean_up.call()
		return
	
	# -------------------------
	# Trash the directory that's current holding the previous version of loggie.
	# Copy the temporarily saved new version files to that directory.

	%ProgressBar.value = 50
	%LabelUpdateStatus.text = "Copying new version files..."
	var zip_reader: ZIPReader = ZIPReader.new()
	var zip_reader_open_error = zip_reader.open(TEMP_ZIP_FILE_PATH)
	if zip_reader_open_error != OK:
		_fail_update("Attempt to open temp. file(s) archive at {path} failed with error: {err_str}".format({
			"path": LOGGIE_PLUGIN_DIR,
			"err_str" : error_string(zip_reader_open_error)
		}))
		clean_up.call()
		return

	OS.move_to_trash(ProjectSettings.globalize_path(LOGGIE_PLUGIN_DIR))
	
	var files : PackedStringArray = zip_reader.get_files()
	var base_path = files[1]
	files.remove_at(0) # Remove archive directory.
	files.remove_at(0) # Remove assets directory.

	for path in files:
		var new_file_path: String = path.replace(base_path, "")
		if path.ends_with("/"):
			print("Creating directory path:", LOGGIE_PLUGIN_DIR + "%s" % new_file_path)
			DirAccess.make_dir_recursive_absolute(LOGGIE_PLUGIN_DIR + "%s" % new_file_path)
		else:
			var abs_path = LOGGIE_PLUGIN_DIR + "%s" % new_file_path
			var file : FileAccess = FileAccess.open(abs_path, FileAccess.WRITE)
			if file == null:
				push_error("Error while storing buffer data into temporary files - write target directory/file {dir} error code {ec}.".format({
					"ec" : FileAccess.get_open_error(), 
					"dir" : abs_path
				}))
			else:
				print("Storing to: ", path)
				var file_content = zip_reader.read_file(path)
				file.store_buffer(file_content)

	# -------------------------
	# Ensure to move over the user's `custom_settings.gd` if it existed in the previous version.
	%ProgressBar.value = 85
	%LabelUpdateStatus.text = "Copying new version files..."
	var CUSTOM_SETTINGS_IN_PREV_VER_PATH = TEMP_PREV_VER_FILES_DIR_PATH.path_join("custom_settings.gd")
	if FileAccess.file_exists(CUSTOM_SETTINGS_IN_PREV_VER_PATH):
		var CUSTOM_SETTINGS_IN_NEW_VER_PATH = ProjectSettings.globalize_path(LOGGIE_PLUGIN_DIR.path_join("custom_settings.gd"))
		var custom_settings_copy_error = DirAccess.copy_absolute(CUSTOM_SETTINGS_IN_PREV_VER_PATH, CUSTOM_SETTINGS_IN_NEW_VER_PATH)
		if custom_settings_copy_error != OK:
			_fail_update("Attempt to copy the 'custom_settings.gd' file from {p1} to {p2} failed with error: {error}".format({
				"p1" : CUSTOM_SETTINGS_IN_PREV_VER_PATH,
				"p2" : CUSTOM_SETTINGS_IN_NEW_VER_PATH,
				"error" : error_string(custom_settings_copy_error)
			}))
			zip_reader.close()
			clean_up.call()
			return

	# ------------------------
	# Clean up temporarily created files and close filewrite.
	%ProgressBar.value = 90
	%LabelUpdateStatus.text = "Cleaning up..."
	zip_reader.close()
	clean_up.call()
	
	# ------------------------
	# Finish up.
	%ProgressBar.value = 100
	_succeed_update()

func _succeed_update():
	%LabelMainStatus.text = "Updated"
	%LabelUpdateStatus.text = "Update complete."
	%OptionExitBtn.visible = true
	%OptionExitBtn.disabled = false
	self.is_currently_updating = false

func _fail_update(status : String):
	%LabelMainStatus.text = "Failed"
	%LabelUpdateStatus.text = status
	%OptionExitBtn.disabled = false
	%OptionExitBtn.visible = true
	%OptionRetryUpdateBtn.disabled = false
	%OptionRetryUpdateBtn.visible = true
	self.is_currently_updating = false

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
