@tool
## A class that can be used to inquire about, generate, and operate on [LoggieVersion]s. 
## It is also responsible for notifying about an available update, and starting it, if configured to do so.
class_name LoggieVersionManager extends RefCounted

## Emitted when this version manager updates the known [member latest_version].
signal latest_version_updated()

## The path to Loggie's plugin.cfg file. Required to read the current version of Loggie.
const CONFIG_PATH = "res://addons/loggie/plugin.cfg"

## The URL where loggie releases on GitHub can be found.
const REMOTE_RELEASES_URL = "https://api.github.com/repos/Shiva-Shadowsong/loggie/releases"

## Stores the result of reading the Loggie version with [method get_current_Version].
var version : LoggieVersion = null

## Stores the result of reading the latest Loggie version with [method get_latest_version].
var latest_version : LoggieVersion = null

## Stores a reference to a ConfigFile which will be loaded from [member CONFIG_PATH] during [method find_and_store_current_version].
var config : ConfigFile = ConfigFile.new()

## Stores a reference to the logger that's using this version manager.
var _logger : Variant = null

## Internal debug variable.
## If not null, this version manager will treat the [LoggieVersion] provided under this variable to be the current [param version].
## Useful for debugging this module when you want to simulate that the current version is something different than it actually is.
var _version_proxy : LoggieVersion = LoggieVersion.new(1, 2)

## Initializes this version manager, connecting it to the logger that's using it and updating the version cache based on that logger,
## which will further prompt the emission of signals in this class, and so on.
func connect_logger(logger : Variant) -> void:
	self.latest_version_updated.connect(on_latest_version_updated)
	self._logger = logger
	update_version_cache()

## Returns a reference to the logger object that is using this version manager.
func get_logger() -> Variant:
	return self._logger

## Reads the current version of Loggie from plugin.cfg and stores it in [member version].
func find_and_store_current_version():
	# Load data from a file.
	var err = config.load(CONFIG_PATH)

	# If the file didn't load, ignore it.
	if err == OK:
		for section in config.get_sections():
			if section == "plugin":
				if self._version_proxy != null:
					self.version = self._version_proxy
				else:
					var version_string = config.get_value(section, "version", "")
					self.version = LoggieVersion.from_string(version_string)
				self.get_logger().debug("Current version of Loggie:", self.version)
	else:
		push_error("Failed to load the Loggie plugin.cfg file. Ensure that loggie_version_manager.gd -> CONFIG_PATH is pointing correctly to a valid plugin.cfg file.")

## Reads the latest version of Loggie from a GitHub API response and stores it in [member latest_version].
func find_and_store_latest_version():
	var loggie = self.get_logger()
	var http_request = HTTPRequest.new()
	loggie.add_child(http_request)
	loggie.debug("Retrieving version(s) info from endpoint:", REMOTE_RELEASES_URL)
	http_request.request_completed.connect(_on_get_latest_version_request_completed, CONNECT_ONE_SHOT)
	http_request.request(REMOTE_RELEASES_URL)

## Defines what happens once this version manager emits the signal saying that an update is available.
func on_update_available_detected() -> void:
	var loggie= self.get_logger()
	if loggie.settings.update_check_mode == LoggieEnums.UpdateCheckType.DONT_CHECK:
		return
	
	var update : LoggieUpdate = LoggieUpdate.new(self.version, self.latest_version)
	update._logger = loggie

	var github_data = self.latest_version.get_meta("github_data")
	var latest_release_notes_url = github_data.html_url
	update.set_release_notes_url(latest_release_notes_url)
	loggie.add_child(update)
	
	match loggie.settings.update_check_mode:
		LoggieEnums.UpdateCheckType.CHECK_AND_SHOW_UPDATER_WINDOW:
			create_and_show_updater_widget(update)
		LoggieEnums.UpdateCheckType.CHECK_AND_SHOW_MSG:
			loggie.set_domain_enabled(update.REPORTS_DOMAIN, true)
			update.try_start()

## Defines what happens when the request to GitHub API which grabs all the Loggie releases is completed.
func _on_get_latest_version_request_completed(result : int, response_code : int, headers : PackedStringArray, body: PackedByteArray):
	var loggie = self.get_logger()
	loggie.debug("Response for request received:", response_code)

	if result != HTTPRequest.RESULT_SUCCESS: 
		return

	var response = JSON.parse_string(body.get_string_from_utf8())

	if typeof(response) != TYPE_ARRAY:
		loggie.error("The response parsed from GitHub was not an array. Response received in an unsupported format.")
		return
	
	var latest_version_data = response[0] # GitHub releases are in order of creation, so grab the first one from the response, that's the latest one.
	self.latest_version = LoggieVersion.from_string(latest_version_data.tag_name)
	self.latest_version.set_meta("github_data", latest_version_data)

	loggie.debug("Latest version of Loggie:", self.latest_version)
	latest_version_updated.emit()

## Executes every time this version manager updates the known latest_version.
func on_latest_version_updated() -> void:
	var loggie = self.get_logger()
	if loggie == null:
		return

	# Check if update is available.
	if is_update_available():
		on_update_available_detected()
	else:
		loggie.debug("You are using the latest version.")
		
## Displays the widget which informs the user of the available update and offers actions that they can take next.
func create_and_show_updater_widget(update : LoggieUpdate) -> LoggieUpdatePrompt:
	var loggie = self.get_logger()
	var _popup = Window.new()
	update.succeeded.connect(func():
		_popup.request_attention()
		_popup.grab_focus()
	)
	
	var widget : LoggieUpdatePrompt = load("res://addons/loggie/version_management/update_prompt_window.tscn").instantiate()
	widget.connect_to_update(update)
	widget.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	EditorInterface.get_base_control().add_child(_popup)
		
	var on_close_requested = func():
		_popup.queue_free()

	widget._logger = loggie
	widget.close_requested.connect(on_close_requested, CONNECT_ONE_SHOT)
	_popup.close_requested.connect(on_close_requested, CONNECT_ONE_SHOT)
	_popup.borderless = false
	_popup.unresizable = true
	_popup.transient = true
	_popup.title = "Update Available"
	_popup.popup_centered(widget.host_window_size)
	_popup.add_child(widget)

	return widget

## Updates the local variables which point to the current and latest version of Loggie.
func update_version_cache():
	# Read and cache the current version of Loggie from plugin.cfg.
	find_and_store_current_version()

	# Read and cache the latest version of Loggie from GitHub.
	var logger = self.get_logger()
	if logger is Node:
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
