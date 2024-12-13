class_name LoggieVersionManager extends RefCounted

## THe path to Loggie's plugin.cfg file.
const CONFIG_PATH = ""

## The URL where loggie releases on GitHub can be found.
const REMOTE_RELEASES_URL = "https://api.github.com/repos/Shiva-Shadowsong/loggie/releases"

## Stores the result of reading the Loggie version with [method get_current_Version].
var version = ""

## Stores a reference to the plugin.cfg config file used by Loggie.
var config : ConfigFile = ConfigFile.new()

func initialize() -> void:
	# Read and cache the current version of Loggie from plugin.cfg.
	get_current_version()
	
	var current_version_breakdown = get_version_breakdown_from_string(version)
	

## Given a version string, recognizes what the major and minor version are from that string,
## and returns a dictionary with keys [param major] and [param minor] that hold a string value.
func get_version_breakdown_from_string(version_string : String) -> Dictionary:
	var breakdown = {
		"major" : "0",
		"minor" : "0",
	}
	
	# Create regex to match version numbers
	var regex = RegEx.new()
	regex.compile("(\\d+)\\.(\\d+)")
	
	var result = regex.search(version_string)
	if result:
		breakdown.major = result.get_string(1)
		breakdown.minor = result.get_string(2)
	
	return breakdown
	
## Returns the current [member version] of Loggie.
## If it hasn't been read yet, it reads it from the plugin.cfg file.
func get_current_version() -> String:
	if self.version != "":
		return self.version
	
	# Load data from a file.
	var err = config.load(CONFIG_PATH)

	# If the file didn't load, ignore it.
	if err != OK:
		push_error("Failed to load the Loggie plugin.cfg file. Ensure that loggie_version_manager.gd -> CONFIG_PATH is pointing correctly to a valid plugin.cfg file.")
		return ""

	# Iterate over all sections.
	for section in config.get_sections():
		if section == "plugin":
			version = config.get_value(section, "version", "")
	
	return version

## Returns the newest version of Loggie by detecting what's in the plugin.cfg file in the
## main branch of the Loggie GitHub repository.
func get_newest_version() -> String:
	var http_request = HTTPRequest.new()
	Loggie.add_child(http_request)
	http_request.request_completed.connect(_on_get_newest_version_request_completed, CONNECT_ONE_SHOT)
	http_request.request(REMOTE_RELEASES_URL)
	return ""
	
func _on_get_newest_version_request_completed(result : int, response_code : int, headers : PackedStringArray, body: PackedByteArray):
	if result != HTTPRequest.RESULT_SUCCESS: 
		return
	
	var response = JSON.parse_string(body.get_string_from_utf8())
	if typeof(response) != TYPE_ARRAY:
		return
		
	# GitHub releases are in order of creation, not order of version
	var versions = (response as Array).filter(func(release):
		var version: String = release.tag_name.substr(1)
		var major_version: int = version.split(".")[0].to_int()
		
		var current_version_breakdown = get_version_breakdown_from_string(self.version)
		var current_major_version: int = current_version_breakdown.major.to_int()
		return major_version == current_major_version and version_to_number(version) > version_to_number(current_version)
	)
	
	
