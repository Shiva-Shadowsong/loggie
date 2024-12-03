
# 📚User Guide

Loggie allows you to compose and style messages then send them to the output, where they will be preprocessed and amended with additional details (such as timestamps, class names, debug level indicators, etc.) - then pushed to the console.

Let's explore some of the features.

# 📋 Table of Contents
- [📚User Guide](#user-guide)
- [📋 Table of Contents](#-table-of-contents)
- [Log Files and Storage](#log-files-and-storage)
- [Composing Messages](#composing-messages)
- [Adjusting Message Formats](#adjusting-message-formats)
- [Preprocessing](#preprocessing)
	- [Eligibility Checks:](#eligibility-checks)
			- [Log Levels](#log-levels)
			- [Domains](#domains)
	- [Preprocess Features](#preprocess-features)
		- [Terminal Mode](#terminal-mode)
			- [• BBCode](#-bbcode)
			- [• ANSI](#-ansi)
			- [• Plain](#-plain)
		- [Class Name Derivation](#class-name-derivation)
		- [Timestamps](#timestamps)
- [Custom Settings](#custom-settings)
- [Using a custom singleton name](#using-a-custom-singleton-name)
			- [• Step 1:](#-step-1)
			- [• Step 2:](#-step-2)
			- [• Step 3:](#-step-3)
- [Notable Technicalities](#notable-technicalities)

----------------------------------------

# Log Files and Storage
Loggie uses Godot's `print` (and other print-adjacent functions) for output. 
Godot already has a neat default logging system which takes care of generating logs for `print`-ed messages and auto-deprecating them when certain thresholds are reached.

Loggie is not reinventing anything in this regard, therefore, if you read about how Godot's default logging system works, you'll know what to expect from Loggie.

You can modify the properties for Godot's logging in the Project Settings -> Debug -> File Logging tab.
![GodotLogging](https://i.imgur.com/CfozCS8.png)

Hover over each setting for more information.

----------------------------------------
# Composing Messages

This part of the guide has been moved to a different page - click here to visit:

 [<img src="https://i.imgur.com/wPuyQjT.png">](MESSAGE_CUSTOMIZATION.md)

# Adjusting Message Formats
You have 2 options. 

You can either:
* Use a 'Custom Settings' file, which is covered [here](#custom-settings).
* Open Godot's Project Settings -> Loggie -> Formatting

If you decide to use Project Settings to store your loggie settings, be advised that this is then stored in your .project file therefore you will be enforced on all other team members who use the same .project file.
If you are not working solo, it's better to use the 'Custom Settings' [file](#custom-settings).

# Preprocessing
All LoggieMsgs, before being output, are preprocessed, unless `preprocessed(false)` is called on them. During the preprocess step, the messages are inspected for eligibility to be logged, and then possibly further altered in various ways which can be finetuned through settings.

## Eligibility Checks:
#### Log Levels
* Messages that are coming from a log_level which is not currently enabled will not be further processed nor logged.
* There are currently 5 log levels: ERROR, WARN, NOTICE, INFO, DEBUG.
* Setting a log level as enabled also counts all levels lower than that one as enabled.
* A setting allows you to change the used log level of Loggie:
	*  LoggieSettings.log_level
	*  Loggie Project Settings -> General -> Log Level.

#### Domains
* Domains are toggleable channels into which you can place your messages.
* Messages that are coming from a disabled domain will not be further processed nor logged.
* Each domain is simply a string key.
* By default, all messages are in the "" (empty string) domain, which is always enabled.
* To change a message's domain, call the `.domain("domainname")` method onto it.
* To enable or disable a domain, call the `Loggie.set_domain_enabled` method.
```gdscript
	Loggie.set_domain_enabled("ShadowRealm", false)
	Loggie.msg("Hidden message.").domain("ShadowRealm").info()
```
* A setting allows you to include/exclude domain names from the logged messages:
	* LoggieSettings.output_message_domain
	* Loggie Project Settings -> Preprocessing -> Output Message Domain.

* A setting allows you to change the format in which the domain is appended to the message:
	* LoggieSettings.format_domain_prefix

## Preprocess Features
### Terminal Mode
Terminal mode determines the way the final preprocessing step will go.
Based on what the target terminal is, the content of the message will be converted so that it can render properly on that terminal.

* A setting allows you to change the terminal mode:
	* LoggieSettings.terminal_mode
	* Loggie Project Settings -> General -> Terminal Mode

3 terminal modes exist:

#### • BBCode
> The use of this terminal mode is assumed by default since Godot and its debug console use it.
> Conversions will be done from BBCode to other formats.
> Use this terminal mode if you are using Godot's console for previewing the output.
> While this mode is used, the generated `.log` files may still include unwanted BBCode if proper care is not taken to use only `print_rich` compliant BBCode.

#### • ANSI
> The use of this mode is recommended for users that are viewing the console output in a non-Godot console, such as Powershell, Bash, etc. If you are using VSCode or some other external editor to develop your project, use this.

#### • Plain
> Output will be raw plain text. Best for raw output that has to be stored in a `.log` file.
> Most likely, you won't use this mode by picking it manually. Instead - 
> Loggie automatically switches to this mode when it detects that it's running in a Release build with Debug features disabled.
> This is great because during local development, you can use the fancy modes (BBCode / ANSI), and not have to worry that style symbols will appear in the `.log` files on Release.

----------------------------------------

### Class Name Derivation
* Loggie can sniff out the script from which a call to Loggie was made, and by reading its `class_name` clause, figure out the name of the class that called it.
* This feature performs better on Godot 4.3+ because it can use the `Script.get_global_name` method to get the class name without needing to read the file. If the old class extraction method is used, it may induce a small performance penalty if executed frequently on a variety of uncached classes in a short manner, since it performs a FileAccess read.
* This name can then be included in the log if the setting for it is enabled:
	* LoggieSettings.derive_and_show_class_names
	* Loggie Project Settings -> Preprocessing -> Derive and Display Class Names
* A setting allows you to specify what kind of substitute gets printed if a script does not have a `class_name`:
	* LoggieSettings.nameless_class_name_proxy
	* Loggie Project Settings -> Preprocessing -> Nameless Class Name Proxy

**Warning**: This only works if there is a debugger connected to the project while it's running, so it will only be useful during development most of the time. This is because this uses the `get_stack` function, whose documentation explains why it depends on the debugger. Therefore, class name derivation is automatically disabled in non-debug builds.

----------------------------------------

### Timestamps
* Loggie can display timestamps for each logged message.
* They may be either displayed in local system time, or UTC.
* A setting allows you to change whether the timestamps are shown:
	* LoggieSettings.output_timestamps
	* Loggie Project Settings -> Timestamps -> Output Timestamps
* A setting allows you to change whether local time or UTC is used:
	* LoggieSettings.timestamps_use_utc
	* Loggie Project Settings -> Timestamps -> Timestamps use UTC

----------------------------------------

# Custom Settings
Loggie will, before loading the settings from the default settings script (`loggie_settings.gd`), attempt to look for a script called `custom_settings.gd` in the same folder where `loggie.gd` is located.

This script, if it exists, must be a script that *extends* the `LoggieSettings` class.

If Loggie finds this successfully, it will use this script to load the settings instead.
Because that script extends `LoggieSettings`, any setting variable that you don't modify through it will remain at its standard value.

Therefore, you can pick-and-choose what you want to customize, and what you want to leave at default.

In the Loggie folder, you will find a `custom_settings.gd.example` template.

You can rename this to `custom_settings.gd`, change its contents to what you prefer, and it will be good to go.

I recommend that you **gitignore** this file if you are using Git, so that each of your teammates can have their own `custom_settings.gd` which won't be committed or conflicted with anyone else's - allowing them to have their own Loggie customizations locally.

This won't affect how Loggie works in production/release builds, because Loggie automatically switches to a release-friendly mode of output when it detects it's running in Release mode.

----------------------------------------

# Using a custom singleton name
Perhaps you don't like having the autoload singleton of Loggie being called "Loggie", and you'd prefer something you're more used to, like "logger", "log", etc.

You can change the name of the autoload by editing the value of the `loggie_singleton_name` variable in `loggie_settings.gd`.

#### • Step 1:
> Disable the plugin if it is enabled. This will trigger the plugin to automatically remove whichever autoload it added when it was enabled.
> 
> *If you don't disable the plugin and end up changing the singleton name, make sure to go to Project Settings -> Autoloads, and manually delete the previously created autoload with the old name).*

#### • Step 2:
> Change the value of the `loggie_singleton_name` variable.

#### • Step 3:
> Re-enable the plugin.

----------------------------------------

# Notable Technicalities
Loggie, by default, assumes that all text it is processing is text which is supported by `print_rich` - so, BBCode content and support is assumed by default.

If it requires to do a conversion to ANSI sequences due to the **Terminal Mode** setting, it will do that at the end of the Preprocessing step, and will convert BBCode to its ANSI counterpart if possible. Unsupported or otherwise unnecessary BBCode will be stripped.

 As per the `print_rich` documentation, supported colors are (by name): black, red, green, yellow, blue, magenta, pink, purple, cyan, white, orange, gray.
Any other color will be displayed in the Godot console or an ANSI based console, but the color tag (in case of BBCode) won't be properly stripped when written to the .log file, resulting in BBCode visible in .log files.

Therefore, if you want to use supported colors, always write them as `[color=red]` or use `.color(Color.RED)` which will automatically handle the rest for you.

----
