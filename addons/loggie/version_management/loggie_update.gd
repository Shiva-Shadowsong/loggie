@tool
class_name LoggieUpdate extends Node

## Emitted when this update fails.
signal failed()

## Emitted when this update succeeds.
signal succeeded()

## Emitted when this declares that it has made some progress.
signal progress(value : float)

## Emitted when this declares that it wants a new status/substatus message to be used.
signal status_changed(status_msg : Variant, substatus_msg : Variant)

## Emitted when this update is starting.
signal starting()

## Emitted when the 'is_in_progress' status of this update changes.
signal is_in_progress_changed(new_value : bool)

## The path to the directory that should have a temporary file created and filled with the patch zipball buffer.
const TEMP_FILES_DIR = "user://"

## If this is set to a non-empty string, it will be used as the directory into which the new update will be
## installed. Used for testing/debugging. When set to empty string, Loggie will automatically figure out
## where it is being updated from and use that directory instead.
const ALT_LOGGIE_PLUGIN_CONTAINER_DIR = ""

## The domain from which status report [LoggieMsg]s from this update will be logged from.
const REPORTS_DOMAIN : String = "loggie_update_status_reports"

## Stores a reference to the logger that's requesting this update.
var _logger : Variant

## The URL used to visit a page that contains the release notes for this update.
var release_notes_url = ""

## Stores a reference to the previous version the connected [member _logger] is/was using.
var prev_version : LoggieVersion = null

## Stores a reference to the new version the connected [member _logger] should be using after the update.
var new_version : LoggieVersion = null

## Indicates whether this update is currently in progress.
var is_in_progress : bool = false

## Whether the update should retain or purge the backup it makes of the previous version files once it is done
## installing and applying the new update.
var _clean_up_backup_files : bool = true

func _init(_prev_version : LoggieVersion, _new_version : LoggieVersion) -> void:
	self.prev_version = _prev_version
	self.new_version = _new_version

## Returns a reference to the logger that's requesting this update.
func get_logger() -> Variant:
	return self._logger
	
## Sets the URL used to visit a page that contains the release notes for this update.
func set_release_notes_url(url : String) -> void:
	self.release_notes_url = url

## Sets whether this window is currently performing the update.
func set_is_in_progress(value : bool) -> void:
	self.is_in_progress = value
	self.is_in_progress_changed.emit(value)

## Tries to start the version update. Prevents the update from starting
## if something is not configured correctly and pushes a warning/error.
func try_start():
	if Engine.has_meta("LoggieUpdateSuccessful") and Engine.get_meta("LoggieUpdateSuccessful"):
		# No plan to allow multiple updates to run during a single Engine session anyway so no need to start another one.
		# Also, this helps with internal testing of the updater and prevents an updated plugin from auto-starting another update
		# when dealing with proxy versions.
		return

	if self._logger == null:
		push_warning("Attempt to start Loggie update failed - member '_logger' on the LoggieUpdate object is null.")
		return

	if self.is_in_progress:
		push_warning("Attempt to start Loggie update failed - the update is already in progress.")
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
	
	_start()
	
## Internal function. Starts the updating of the [param _logger] to the [param new_version].
## Do not run without verification that configuration is correct.
## Use [method try_start] to call this safely.
func _start():
	var loggie = self.get_logger()

	loggie.msg("Loggie is updating from version {v_prev} to {v_new}.".format({
		"v_prev" : self.prev_version,
		"v_new" : self.new_version
	})).domain(REPORTS_DOMAIN).color(Color.ORANGE).box(12).info()
	
	set_is_in_progress(true)
	starting.emit()

	# Make request to configured endpoint.
	var update_data = self.new_version.get_meta("github_data")
	var http_request = HTTPRequest.new()
	loggie.add_child(http_request)
	http_request.request_completed.connect(_on_download_request_completed)
	http_request.request(update_data.zipball_url)

## Internal callback function. 
## Defines what happens when new update content is successfully downloaded from GitHub.
## Called automatically during [method _start] if everything is going according to plan.
func _on_download_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var loggie = self.get_logger()

	if loggie == null:
		_failure("The _logger used by the updater window is null.")
		return

	if result != HTTPRequest.RESULT_SUCCESS:
		_failure("Download request returned non-zero code: " + str(result))
		return

	#region || Prepare: Define variables and callbacks that will be used throughout.
	# The path to the directory which is supposed to contain the plugin directory.
	# This will usually be 'res://addons/', but could be anything else too. We'll read it dynamically
	# from the connected logger to guarantee correctness.
	var LOGGIE_PLUGIN_CONTAINER_DIR = ALT_LOGGIE_PLUGIN_CONTAINER_DIR if !ALT_LOGGIE_PLUGIN_CONTAINER_DIR.is_empty() else loggie.get_directory_path().get_base_dir() + "/"
	
	# The path to the `loggie` plugin directory.
	var LOGGIE_PLUGIN_DIR = ProjectSettings.globalize_path(LOGGIE_PLUGIN_CONTAINER_DIR.path_join("loggie/"))
	
	# The full path filename of the temporary .zip archive that will be created to store the downloaded data.
	var TEMP_ZIP_FILE_PATH = ProjectSettings.globalize_path(TEMP_FILES_DIR.path_join("_temp_loggie_{ver}.zip".format({"ver": str(new_version)})))
	
	# The path to the directory where a temporary backup of current loggie plugin files will be copied to.
	# (will be created if doesn't exist).
	var TEMP_PREV_VER_FILES_DIR_PATH = ProjectSettings.globalize_path(TEMP_FILES_DIR.path_join("_temp_loggie_{ver}_backup".format({"ver": str(prev_version)})))
	
	# A callable that can be reused within this function that cleans up the temporary and unused directories,
	# once this function comes to a conclusion.
	var clean_up : Callable = func():
		if FileAccess.file_exists(TEMP_ZIP_FILE_PATH):
			OS.move_to_trash(TEMP_ZIP_FILE_PATH)
		if DirAccess.dir_exists_absolute(TEMP_PREV_VER_FILES_DIR_PATH) and self._clean_up_backup_files:
			OS.move_to_trash(TEMP_PREV_VER_FILES_DIR_PATH)

	# A callable that can be used to replace the currently existing Loggie plugin directory
	# with whatever is currently (temporarily) stored as its backup.
	var revert_to_backup = func():
		if FileAccess.file_exists(LOGGIE_PLUGIN_DIR):
			OS.move_to_trash(LOGGIE_PLUGIN_DIR)
		if DirAccess.dir_exists_absolute(TEMP_PREV_VER_FILES_DIR_PATH):
			DirAccess.rename_absolute(TEMP_PREV_VER_FILES_DIR_PATH, LOGGIE_PLUGIN_DIR)
			
	#endregion

	#region || Step 1: Store the downloaded content into a temporary zip file.
	send_progress_update(20, "Processing Files", "Storing patch locally...")

	var zip_file: FileAccess = FileAccess.open(TEMP_ZIP_FILE_PATH, FileAccess.WRITE)
	if zip_file == null:
		_failure("Failed to open temp. file for writing: {path}".format({"path": TEMP_ZIP_FILE_PATH}))
		clean_up.call()
		return

	zip_file.store_buffer(body)
	zip_file.close()
	#endregion

	#region || Step 2: Make a temporary backup of the currently used Loggie plugin directory.
	send_progress_update(30, "Processing Files", "Backing up previous version files...")
	
	if !DirAccess.dir_exists_absolute(LOGGIE_PLUGIN_DIR):
		_failure("The Loggie plugin directory ({path}) could not be found.".format({
			"path" : LOGGIE_PLUGIN_DIR
		}))
		clean_up.call()
		return

	var copy_prev_ver_result = LoggieTools.copy_dir_absolute(LOGGIE_PLUGIN_DIR, TEMP_PREV_VER_FILES_DIR_PATH, true)
	if copy_prev_ver_result.errors.size() > 0:
		var copy_prev_var_result_errors_msg = LoggieMsg.new("Errors encountered:")
		for error in copy_prev_ver_result.errors:
			copy_prev_var_result_errors_msg.nl().add(error_string(error))
		_failure(copy_prev_var_result_errors_msg.string())
		clean_up.call()
		return
	#endregion

	#region || Step 3: Remove currently used Loggie plugin directory and create a new one in its place populated with new version files.
	send_progress_update(50, "Processing Files", "Copying new version files...")
	var zip_reader: ZIPReader = ZIPReader.new()
	var zip_reader_open_error = zip_reader.open(TEMP_ZIP_FILE_PATH)
	if zip_reader_open_error != OK:
		_failure("Attempt to open temp. file(s) archive at {path} failed with error: {err_str}".format({
			"path": LOGGIE_PLUGIN_DIR,
			"err_str" : error_string(zip_reader_open_error)
		}))
		clean_up.call()
		return
	
	# Trash the previously existing loggie plugin dir entirely.
	# A new one will be created in a moment.
	OS.move_to_trash(LOGGIE_PLUGIN_DIR)
	
	# Get a list of all files and dirs in the zip.
	var files : PackedStringArray = zip_reader.get_files() 

	# This will always be the "addons" directory in the zip archive in which we expect
	# to find the "loggie" directory containing the plugin.
	var base_path_in_zip = files[1] 

	# Remove the first 2 parts of the path that we won't be needing at all.
	files.remove_at(0)
	files.remove_at(0)

	# Create all needed files and directories.
	for path in files:
		var new_file_path: String = path.replace(base_path_in_zip, "")
		if path.ends_with("/"):
			DirAccess.make_dir_recursive_absolute(LOGGIE_PLUGIN_CONTAINER_DIR + new_file_path)
		else:
			var abs_path = LOGGIE_PLUGIN_CONTAINER_DIR + new_file_path
			var file : FileAccess = FileAccess.open(abs_path, FileAccess.WRITE)
			if file == null:
				_failure("Error while storing buffer data into temporary files - write target directory or file {target} gave the error: {error}".format({
					"error" : error_string(FileAccess.get_open_error()), 
					"target" : abs_path
				}))
				revert_to_backup.call()
				clean_up.call()
				return
			else:
				var file_content = zip_reader.read_file(path)
				file.store_buffer(file_content)
				file.close()

	zip_reader.close()
	#endregion

	#region || Step 4: Move the user's 'custom_settings.gd' to the new version directory if it existed in prev version.
	send_progress_update(70, "Processing Files", "Reapplying custom settings...")
	var CUSTOM_SETTINGS_IN_PREV_VER_PATH = TEMP_PREV_VER_FILES_DIR_PATH.path_join("custom_settings.gd")
	if FileAccess.file_exists(CUSTOM_SETTINGS_IN_PREV_VER_PATH):
		var CUSTOM_SETTINGS_IN_NEW_VER_PATH = ProjectSettings.globalize_path(LOGGIE_PLUGIN_DIR.path_join("custom_settings.gd"))
		var custom_settings_copy_error = DirAccess.copy_absolute(CUSTOM_SETTINGS_IN_PREV_VER_PATH, CUSTOM_SETTINGS_IN_NEW_VER_PATH)
		if custom_settings_copy_error != OK:
			push_error("Attempt to copy the 'custom_settings.gd' file from {p1} to {p2} failed with error: {error}".format({
				"p1" : CUSTOM_SETTINGS_IN_PREV_VER_PATH,
				"p2" : CUSTOM_SETTINGS_IN_NEW_VER_PATH,
				"error" : error_string(custom_settings_copy_error)
			}))
	#endregion

	#region || Step 5: Move the user's 'channels/custom_channels' directory to the new version if it existed in prev version.
	send_progress_update(80, "Processing Files", "Reapplying custom channels...")
	var CUSTOM_CHANNELS_IN_PREV_VER_PATH = ProjectSettings.globalize_path(TEMP_PREV_VER_FILES_DIR_PATH.path_join("channels/custom_channels/"))
	if DirAccess.dir_exists_absolute(CUSTOM_CHANNELS_IN_PREV_VER_PATH):
		var CUSTOM_CHANNELS_IN_NEW_VER_PATH = ProjectSettings.globalize_path(LOGGIE_PLUGIN_DIR.path_join("channels/custom_channels/"))
		var copy_prev_ver_custom_channels_result = LoggieTools.copy_dir_absolute(CUSTOM_CHANNELS_IN_PREV_VER_PATH, CUSTOM_CHANNELS_IN_NEW_VER_PATH, true)
		if copy_prev_ver_custom_channels_result.errors.size() > 0:
			var copy_prev_var_result_errors_msg = LoggieMsg.new("Errors encountered:")
			for error in copy_prev_ver_result.errors:
				copy_prev_var_result_errors_msg.nl().add(error_string(error))
			push_error("Attempt to copy the 'channels/custom_channels' directory from {p1} to {p2} failed with error: {error}".format({
				"p1" : CUSTOM_CHANNELS_IN_PREV_VER_PATH,
				"p2" : CUSTOM_CHANNELS_IN_NEW_VER_PATH,
				"error" : copy_prev_var_result_errors_msg.string()
			}))
	else:
		print("The {path} directory doesn't exist.".format({"path": CUSTOM_CHANNELS_IN_PREV_VER_PATH}))
	#endregion

	#region || Step 6: Clean up temporarily created files and close filewrite.
	send_progress_update(90, "Processing Files", "Cleaning up...")
	clean_up.call()
	#endregion
	
	#region || Step 7: Declare successful. Wrap up.
	send_progress_update(100, "Finishing up", "")
	_success()
	#endregion

## Internal function used at the end of the updating process if it is successfully completed.
func _success():
	set_is_in_progress(false)

	var msg = "💬 You may see temporary errors in the console due to Loggie files being re-scanned and reloaded on the spot.\nIt should be safe to dismiss them, but for the best experience, reload the Godot editor (and the plugin, if something seems wrong).\n\n🚩 If you see a 'Files have been modified on disk' window pop up, choose 'Discard local changes and reload' to accept incoming changes."
	status_changed.emit(null, msg)
	succeeded.emit()

	print_rich(LoggieMsg.new("👀 Loggie updated to version {new_ver}!".format({"new_ver": self.new_version})).bold().color(Color.ORANGE).string())
	print_rich(LoggieMsg.new("\t📚 Release Notes: ").bold().msg("[url={url}]{url}[/url]".format({"url": release_notes_url})).color(Color.CORNFLOWER_BLUE).string())
	print_rich(LoggieMsg.new("\t💬 Support, Development & Feature Requests: ").bold().msg("[url=https://discord.gg/XPdxpMqmcs]https://discord.gg/XPdxpMqmcs[/url]").color(Color.CORNFLOWER_BLUE).string())

	if Engine.is_editor_hint():
		var editor_plugin = Engine.get_meta("LoggieEditorPlugin")
		editor_plugin.get_editor_interface().get_resource_filesystem().scan()
		editor_plugin.get_editor_interface().call_deferred("set_plugin_enabled", "loggie", true)
		editor_plugin.get_editor_interface().set_plugin_enabled("loggie", false)
		Engine.set_meta("LoggieUpdateSuccessful", true)
		print_rich("[b]Updater:[/b] ", msg)

## Internal function used to interrupt an ongoing update and cause it to fail.
func _failure(status_msg : String):
	var loggie = self.get_logger()
	loggie.msg(status_msg).color(Color.SALMON).preprocessed(false).error()
	loggie.msg("\t💬 If this issue persists, consider reporting: ").bold().msg("https://github.com/Shiva-Shadowsong/loggie/issues").color(Color.CORNFLOWER_BLUE).preprocessed(false).info()
	set_is_in_progress(false)
	failed.emit()
	status_changed.emit(null, status_msg)

## Informs the listeners of the [signal progress] / [signal status_changed] signals about a change in the progress of the update.
func send_progress_update(progress_amount : float, status_msg : String, substatus_msg : String):
	var loggie = self.get_logger()
	if !substatus_msg.is_empty():
		loggie.msg("•• ").msg(substatus_msg).domain(REPORTS_DOMAIN).preprocessed(false).info()
	progress.emit(progress_amount)
	status_changed.emit(status_msg, substatus_msg)
