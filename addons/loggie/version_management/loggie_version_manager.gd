@tool
## A class that can be used to inquire about, generate, and operate on [LoggieVersion]s. 
## It is also responsible for notifying about an available update, and starting it, if configured to do so.
class_name LoggieVersionManager extends RefCounted

## Emitted when this version manager updates the known [member latest_version].
signal latest_version_updated()

## Emitted when this version manager has created a valid [LoggieUpdate] and is ready to use it.
signal update_ready()

## The URL where loggie releases on GitHub can be found.
const REMOTE_RELEASES_URL = "https://api.github.com/repos/Shiva-Shadowsong/loggie/releases"

## The domain from which [LoggieMsg]s from this version manager will be logged from.
const REPORTS_DOMAIN : String = "loggie_version_check_reports"

## Stores the result of reading the Loggie version with [method get_current_Version].
var version : LoggieVersion = null

## Stores the result of reading the latest Loggie version with [method get_latest_version].
var latest_version : LoggieVersion = null

## Stores a reference to a ConfigFile which will be loaded from [member CONFIG_PATH] during [method find_and_store_current_version].
var config : ConfigFile = ConfigFile.new()

## Stores a reference to the logger that's using this version manager.
var _logger : Variant = null

## Stores a reference to the [LoggieUpdate] that has been created to handle an available update.
var _update : LoggieUpdate = null

## Internal debug variable.
## If not null, this version manager will treat the [LoggieVersion] provided under this variable to be the current [param version].
## Useful for debugging this module when you want to simulate that the current version is something different than it actually is.
var _version_proxy : LoggieVersion = null

## Initializes this version manager, connecting it to the logger that's using it and updating the version cache based on that logger,
## which will further prompt the emission of signals in this class, and so on.
func connect_logger(logger : Variant) -> void:
	self.latest_version_updated.connect(on_latest_version_updated)
	self._logger = logger

	# Set to true during development to enable debug prints related to version management.
	self._logger.set_domain_enabled(self.REPORTS_DOMAIN, false)

	update_version_cache()

## Returns a reference to the logger object that is using this version manager.
func get_logger() -> Variant:
	return self._logger

## Reads the current version of Loggie from plugin.cfg and stores it in [member version].
func find_and_store_current_version():
	var detected_version = self._logger.version
	if self._version_proxy != null:
		self.version = self._version_proxy
		self.version.proxy_for = detected_version
	else:
		self.version = detected_version

## Reads the latest version of Loggie from a GitHub API response and stores it in [member latest_version].
func find_and_store_latest_version():
	var loggie = self.get_logger()
	var http_request = HTTPRequest.new()
	loggie.add_child(http_request)
	loggie.msg("Retrieving version(s) info from endpoint:", REMOTE_RELEASES_URL).domain(REPORTS_DOMAIN).debug()
	http_request.request_completed.connect(_on_get_latest_version_request_completed, CONNECT_ONE_SHOT)
	http_request.request(REMOTE_RELEASES_URL)

## Defines what happens once this version manager emits the signal saying that an update is available.
func on_update_available_detected() -> void:
	var loggie = self.get_logger()
	if loggie.settings.update_check_mode == LoggieEnums.UpdateCheckType.DONT_CHECK:
		return
	
	self._update = LoggieUpdate.new(self.version, self.latest_version)
	self._update._logger = loggie

	var github_data = self.latest_version.get_meta("github_data")
	var latest_release_notes_url = github_data.html_url
	self._update.set_release_notes_url(latest_release_notes_url)
	loggie.add_child(self._update)
	update_ready.emit()

	# No plan to allow multiple updates to run during a single Engine session anyway so no need to start another one.
	# Also, this helps with internal testing of the updater and prevents an updated plugin from auto-starting another update
	# when dealing with proxy versions.
	var hasUpdatedAlready = Engine.has_meta("LoggieUpdateSuccessful") and Engine.get_meta("LoggieUpdateSuccessful")

	match loggie.settings.update_check_mode:
		LoggieEnums.UpdateCheckType.CHECK_AND_SHOW_UPDATER_WINDOW:
			if hasUpdatedAlready:
				loggie.info("Update already performed. ✔️")
				return
			create_and_show_updater_widget(self._update)
		LoggieEnums.UpdateCheckType.CHECK_AND_SHOW_MSG:
			loggie.msg("👀 Loggie update available!").color(Color.ORANGE).header().msg(" > Current version: {version}, Latest version: {latest}".format({
				"version" : self.version,
				"latest" : self.latest_version
			})).info()
		LoggieEnums.UpdateCheckType.CHECK_DOWNLOAD_AND_SHOW_MSG:
			if hasUpdatedAlready:
				loggie.info("Update already performed. ✔️")
				return
			loggie.set_domain_enabled("loggie_update_status_reports", true)
			self._update.try_start()

## Defines what happens when the request to GitHub API which grabs all the Loggie releases is completed.
func _on_get_latest_version_request_completed(result : int, response_code : int, headers : PackedStringArray, body: PackedByteArray):
	var loggie = self.get_logger()
	loggie.msg("Response for request received:", response_code).domain(REPORTS_DOMAIN).debug()

	if result != HTTPRequest.RESULT_SUCCESS: 
		return

	var response = JSON.parse_string(body.get_string_from_utf8())

	if typeof(response) != TYPE_ARRAY:
		loggie.error("The response parsed from GitHub was not an array. Response received in an unsupported format.")
		return
	
	var latest_version_data = response[0] # GitHub releases are in order of creation, so grab the first one from the response, that's the latest one.
	self.latest_version = LoggieVersion.from_string(latest_version_data.tag_name)
	self.latest_version.set_meta("github_data", latest_version_data)

	loggie.msg("Current version of Loggie:", self.version).msg(" (proxy for: {value})".format({"value": self.version.proxy_for})).domain(REPORTS_DOMAIN).debug()
	loggie.msg("Latest version of Loggie:", self.latest_version).domain(REPORTS_DOMAIN).debug()
	latest_version_updated.emit()

## Executes every time this version manager updates the known latest_version.
func on_latest_version_updated() -> void:
	var loggie = self.get_logger()
	if loggie == null:
		return

	# Check if update is available.
	if loggie.settings.update_check_mode != LoggieEnums.UpdateCheckType.DONT_CHECK:
		loggie.msg("👀 Loggie:").bold().color("orange").msg(" Checking for updates...").info()
		if is_update_available():
			on_update_available_detected()
		else:
			loggie.msg("👀 Loggie:").bold().color("orange").msg(" Up to date. ✔️").color(Color.LIGHT_GREEN).info()
		
## Displays the widget which informs the user of the available update and offers actions that they can take next.
func create_and_show_updater_widget(update : LoggieUpdate) -> Window:
	const PATH_TO_WIDGET_SCENE = "addons/loggie/version_management/update_prompt_window.tscn"
	var WIDGET_SCENE = load(PATH_TO_WIDGET_SCENE)
	if !is_instance_valid(WIDGET_SCENE):
		push_error("Loggie Update Prompt Window scene not found on expected path: {path}".format({"path": PATH_TO_WIDGET_SCENE}))
		return

	var loggie = self.get_logger()
	if loggie == null:
		return
	
	var popup_parent = null
	if Engine.is_editor_hint() and Engine.has_meta("LoggieEditorInterfaceBaseControl"):
		popup_parent = Engine.get_meta("LoggieEditorInterfaceBaseControl")
	else:
		popup_parent = SceneTree.current_scene

	# Configure popup window.
	var _popup = Window.new()
	update.succeeded.connect(func():
		_popup.queue_free()
		var success_dialog = AcceptDialog.new()
		var msg = "💬 You may see temporary errors in the console due to Loggie files being re-scanned and reloaded on the spot.\nIt should be safe to dismiss them, but for the best experience, reload the Godot editor (and the plugin, if something seems wrong).\n\n🚩 If you see a 'Files have been modified on disk' window pop up, choose 'Discard local changes and reload' to accept incoming changes."
		success_dialog.dialog_text = msg
		success_dialog.title = "Loggie Updater"
		if is_instance_valid(popup_parent):
			popup_parent.add_child(success_dialog)
			success_dialog.popup_centered()
	)
	var on_close_requested = func():
		_popup.queue_free()

	_popup.close_requested.connect(on_close_requested, CONNECT_ONE_SHOT)
	_popup.borderless = false
	_popup.unresizable = true
	_popup.transient = true
	_popup.title = "Update Available"
	
	# Configure window widget and add it as a child of the popup window.
	var widget : LoggieUpdatePrompt = WIDGET_SCENE.instantiate()
	widget.connect_to_update(update)
	widget.set_anchors_preset(Control.PRESET_FULL_RECT)
	widget._logger = loggie
	widget.close_requested.connect(on_close_requested, CONNECT_ONE_SHOT)
	
	if is_instance_valid(popup_parent):
		popup_parent.add_child(_popup)
		_popup.popup_centered(widget.host_window_size)
	_popup.add_child(widget)

	return _popup

## Updates the local variables which point to the current and latest version of Loggie.
func update_version_cache():
	# Read and cache the current version of Loggie from plugin.cfg.
	find_and_store_current_version()

	# Read and cache the latest version of Loggie from GitHub.
	# (Do it only if running in editor, no need for this if running in a game).
	var logger = self.get_logger()
	if logger is Node:
		if !Engine.is_editor_hint():
			return
		if logger.is_node_ready():
			find_and_store_latest_version()
		else:
			logger.ready.connect(func():
				find_and_store_latest_version()
			, CONNECT_ONE_SHOT)

## Checks if an update for Loggie is available. Run only after running [method update_version_cache].
func is_update_available() -> bool:
	var loggie = self.get_logger()
	if !(self.version is LoggieVersion and self.version.is_valid()):
		loggie.error("The current version of Loggie is not valid. Run `find_and_store_current_version` once to obtain this value first.")
		return false
	if !(self.latest_version is LoggieVersion and self.latest_version.is_valid()):
		loggie.error("The latest version of Loggie is not valid. Run `find_and_store_latest_version` once to obtain this value first.")
		return false
	return self.latest_version.is_higher_than(self.version)
