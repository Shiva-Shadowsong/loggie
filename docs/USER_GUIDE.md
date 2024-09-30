
# User Guide

Loggie allows you to compose and style messages then send them to the output, where they will be preprocessed and amended with additional details (such as timestamps, class names, debug level indicators, etc.) - then pushed to the console.

Let's explore some of the features.

# TOC
- [User Guide](#user-guide)
- [TOC](#toc)
- [Log Files and Storage](#log-files-and-storage)
- [Composing Messages](#composing-messages)
	- [Creating a message](#creating-a-message)
	- [Styling a message](#styling-a-message)
	- [Outputting a message](#outputting-a-message)
- [Adjusting Message Formats](#adjusting-message-formats)
- [Preprocessing](#preprocessing)
	- [Validity Checks:](#validity-checks)
			- [Log Levels](#log-levels)
			- [Domains](#domains)
			- [Class Name Derivation](#class-name-derivation)
			- [Timestamps](#timestamps)
			- [Terminal Mode](#terminal-mode)
- [Custom Settings File](#custom-settings)
- [Notable Technicalities](#notable-technicalities)

# Log Files and Storage
Loggie uses Godot's `print` (and other print-adjacent functions) for output. 
Godot already has a neat default logging system which takes care of generating logs for `print`-ed messages and auto-deprecating them when certain thresholds are reached.

Loggie is not reinventing anything in this regard, therefore, if you read about how Godot's default logging system works, you'll know what to expect from Loggie.

You can modify the properties for Godot's logging in the Project Settings -> Debug -> File Logging tab.
![GodotLogging](https://i.imgur.com/CfozCS8.png)

Hover over each setting for more information.

# Composing Messages

## Creating a message
All messages loggie works with are instances of `LoggieMsg`, a string wrapper class that comes along with a bunch of extra utilities. These are the messages we'll be outputting.

To create a `LoggieMsg` and fill it with some starting content, we can use the `Loggie.msg(...)` helper method:

```
	Loggie.msg("Hello world.")
```

## Styling a message
We can chain various LoggieMsg methods onto that message to style its current content.
For example:

```gdscript
Loggie.msg("Hello world.").bold().color(Color.CYAN)
```

will stylize the current text (`Hello world.`) to be bold and colored cyan.

An up-to-date list and documentation of all methods available for modifying a `LoggieMsg` can be found in the `LoggieMsg` class documentation, which can be read directly in the loggie_message.gd script, or more conveniently, from the Godot "Search Help" window.

![Help](https://camo.githubusercontent.com/2596533eda0d55dc16f94e24eb2c4230e880a329c015a2fc558edfa908de71ea/68747470733a2f2f692e696d6775722e636f6d2f3750495758616d2e706e67)

❗ **Warning:**
Unless documentation indicates otherwise, all modifications by these methods are done to the **current content** of the message, and won't apply to any additional content that is appended to that same message afterwards.

Here is a quick overview of some styles you may use commonly:

------------

##### bold()
> Makes the current content of this message bold.

```gdscript
Loggie.msg("I'm bold.").bold().info()
```
![](https://i.imgur.com/JL5vjlt.png)

------------

##### italic()
> Makes the current content of this message italic.

```gdscript
Loggie.msg("I'm italic.").italic().info()
```
![](https://i.imgur.com/omvar4a.png)

------------

##### header()
> Stylizes the current content of this message as a header.
> You can adjust how this appears in the `format_header` advanced setting. (Only available via the custom_settings.gd, not in Project Settings for now)
> Headers are by default bold + italic.

```gdscript
Loggie.msg("This is a header.").header().info()
```
 ![](https://i.imgur.com/MJq1zDs.png)

------------

##### color(color : String | Color)
> Wraps the current content of this message in the given color. The color can be provided as a Color, a recognized Godot color name (String, e.g. "red"), or a color hex code (String, e.g. "#ff0000").

```gdscript
Loggie.msg("Hello.").color(Color.RED).info()
Loggie.msg("Hello.").color("#ff0000").info()
```
![](https://i.imgur.com/CzVnNxs.png)

------------

##### box(h_padding: int = 4)
> Constructs a decorative box with the given horizontal padding around the current content of this message. Messages containing a box are not going to be preprocessed, so they are best used only as a special header or decoration.

> You can adjust how the box is constructed in the `box_symbols_compatible` and `box_symbols_pretty` advanced setting. (Only available via the custom_settings.gd, not in Project Settings for now).

> You can choose which box type to use with the Loggie Project Settings -> Preprocessing -> Box Characters Mode setting.

```gdscript
Loggie.msg("Let me oooout.").box(6).info()
```
![](https://i.imgur.com/sjiVW1g.png)

------------

##### nl(amount: int = 1)
> Adds the specified amount of newline characters to the end of the current message.

```gdscript
Loggie.msg("New line after me.").nl().info()
```

------------

##### hseparator(size: int = 16, alternative_symbol: Variant = null)
> Appends a horizontal separator with the given length to the message. If alternative_symbol is provided, it should be a String, and it will be used as the symbol for the separator instead of the default one.

```gdscript
# Adds a new line 
Loggie.msg("Very important business.").header().nl().hseparator(20).info()
```
![](https://i.imgur.com/mTEmPgw.png)

------------

##### prefix(prefix : String, separator : String = "")
> Prepends the given prefix string to the start of the message with the provided separator.

```gdscript
Loggie.msg("After").prefix("Before").info()
```

------------

##### suffix(suffix : String, separator : String = "")
> Appends the given suffix string to the end of the message with the provided separator.

```gdscript
Loggie.msg("Before").suffix("After").info()
```

## Outputting a message

To output a message, we must chain one of the output methods as a final call on the constructed message.
There are multiple methods, one for each Debug Level.
The method which is used will dictate the debug level at which that message will be outputted.
If Loggie is not configured to currently have that debug level enabled, the message will not be processed or output.

```gdscript
	Loggie.msg("Something went wrong.").error()
	Loggie.msg("Warning!.").warn()
	Loggie.msg("This is a notice.").notice()
	Loggie.msg("Debug message.").debug()
	Loggie.msg("Regular info message.").info()
```

#### Extras
`warn()` and `error()` messages will only appear in the 'Debugger' tab of Godot, unless the 'Output Errors/Warning Also To Console' is turned on in Loggie Project Settings.

`debug()` messages can be also be configured there to be output using Godot's `print_debug` method instead of the regular `print` / `print_rich` that Loggie usually uses. This makes them show a full stack trace.

# Adjusting Message Formats
Adjusting message formats is currently not supported through the Loggie Project Settings. Instead, you have 2 options. You can either modify `loggie_settings.gd` directly (not recommended) - or use a 'Custom Settings' file, which is covered in the next chapter.

Once you're ready to modify the formats - have a look at `loggie_settings.gd` under the "Formats for prints" code region.
There, you will find all the variables responsible for setting up the default format for the messages.

You can adjust these variables in your Custom Settings to your liking.

# Preprocessing
All LoggieMsgs, before being output, are preprocessed, unless `preprocessed(false)` is called on them. During the preprocess step, the messages are inspected for validity, and further altered in various ways.

## Validity Checks:
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

#### Class Name Derivation
* Loggie can sniff out the script from which a call to Loggie was made, and by reading its `class_name` clause, figure out the name of the class that called it.
* This name can then be included in the log if the setting for it is enabled:
	* LoggieSettings.derive_and_show_class_names
	* Loggie Project Settings -> Preprocessing -> Derive and Display Class Names
* This process may induce a small performance penalty if executed frequently, since it performs a FileAccess read.
* **Warning**: This only works if there is a debugger connected to the project while it's running, so it will only be useful during development most of the time. This is because this uses the `get_stack` function, whose documentation explains why it depends on the debugger. Therefore, class name derivation is automatically disabled in non-debug builds.

#### Timestamps
* Loggie can display timestamps for each logged message.
* They may be either displayed in local system time, or UTC.
* A setting allows you to change whether the timestamps are shown:
	* LoggieSettings.output_timestamps
	* Loggie Project Settings -> Timestamps -> Output Timestamps
* A setting allows you to change whether local time or UTC is used:
	* LoggieSettings.timestamps_use_utc
	* Loggie Project Settings -> Timestamps -> Timestamps use UTC

#### Terminal Mode
Terminal mode determines the way the final preprocessing step will go.
Based on what the target terminal is, the content of the message will be converted so that it can render properly on that terminal.

A setting allows you to change the terminal mode:
	* LoggieSettings.terminal_mode
	* Loggie Project Settings -> General -> Terminal Mode

3 terminal modes exist:

#### BBCode
The use of this terminal mode is assumed by default since Godot and its debug console use it.
Conversions will be done from BBCode to other formats.
Use this terminal mode if you are using Godot's console for previewing the output.
While this mode is used, the generated `.log` files may still include unwanted BBCode if proper care is not taken to use only `print_rich` compliant BBCode.

#### ANSI
The use of this mode is recommended for users that are viewing the console output in a non-Godot console, such as Powershell, Bash, etc. If you are using VSCode or some other external editor to develop your project, use this.

#### Plain
Output will be raw plain text. Use this mode when you want to check how i
Loggie automatically switched to this mode when it detects that it's running in a release build with Debug features disabled.

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

# Notable Technicalities
Loggie, by default, assumes that all text it is processing is text which is supported by `print_rich` - so, BBCode content and support is assumed by default.

If it requires to do a conversion to ANSI sequences due to the **Terminal Mode** setting, it will do that at the end of the Preprocessing step, and will convert BBCode to its ANSI counterpart if possible. Unsupported or otherwise unnecessary BBCode will be stripped.

 As per the `print_rich` documentation, supported colors are (by name): black, red, green, yellow, blue, magenta, pink, purple, cyan, white, orange, gray.
Any other color will be displayed in the Godot console or an ANSI based console, but the color tag (in case of BBCode) won't be properly stripped when written to the .log file, resulting in BBCode visible in .log files.

Therefore, if you want to use supported colors, always write them as `[color=red]` or use `.color(Color.RED)` which will automatically handle the rest for you.

----
