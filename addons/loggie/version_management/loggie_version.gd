## A utility class that helps with storing data about a Loggie Version and converting and comparing version strings.
class_name LoggieVersion extends Resource

var minor : int = -1 ## The minor component of the version.
var major : int = -1 ## The major component of the version.
var proxy_for : LoggieVersion = null ## The version that this version is a proxy for. (Internal use only)

func _init(_major : int = -1, _minor : int = -1) -> void:
	self.minor = _minor
	self.major = _major
	
func _to_string() -> String:
	return str(self.major) + "." + str(self.minor)

## Checks if this version is valid.
## (neither minor nor major component can be less than 0).
func is_valid() -> bool:
	return (minor >= 0 and major >= 0)

## Checks if the given [param version] if higher than this version.
func is_higher_than(version : LoggieVersion):
	if self.major > version.major:
		return true
	if self.minor > version.minor:
		return true
	return false

## Given a string that has 2 sets of digits separated by a ".", breaks that down
## into a version with a major and minor version component (ints).
static func from_string(version_string : String) -> LoggieVersion:
	var version : LoggieVersion = LoggieVersion.new()
	var regex = RegEx.new()
	regex.compile("(\\d+)\\.(\\d+)")
	
	var result = regex.search(version_string)
	if result:
		version.major = result.get_string(1).to_int()
		version.minor = result.get_string(2).to_int()
	return version
