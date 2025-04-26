## ![](https://i.imgur.com/Cq5QBYC.png) Automatically makes clean plaintext logs in Release builds

Loggie can create some fancy looking output, but you don't want to open a .log file from an user who ran your project on release and realize your .log files are filled with BBCode or ANSI sequences, which were helpful during development... but now are simply creating a mess.

Loggie automatically switches to producing clean plaintext logs when it detects that your project is running in Release mode.

### How does it do that?

It uses a simple function with an assumption:

```gdscript
func is_in_production() -> bool:
    return OS.has_feature("release")
```

If this returns `true`, Loggie acts like it is running in production / released mode.

### Running in Production

While running in production, Loggie alters some of its behaviors.

If the `LoggieSetting.enforce_optimal_settings_in_release_build` is set to `true` (can also be done in **Project Settings -> Loggie -> General**):
	* Loggie will automatically set the [Output Format Mode](OUTPUT_FORMAT_MODES.md) to **PLAIN**. *This means that all logs it outputs will be stripped of BBCode styling tags.*
	* It sets the `BoxCharactersMode` to **Compatible**, which means that if you use the `msg.box()` function, it will create a box using **Compatible** symbols, which we are certain can render and stay spaced out properly even in a plain .txt file.

The other side-effects are:
1. The used Discord channel webhook will switch from the 'Dev' webhook to 'Live' webhook.
2. The used Slack channel webhook will switch from the 'Dev' webhook to 'Live' webhook.

You can see whether Loggie thinks its running in production, and more about used Loggie settings, if you set the **Project Settings -> Loggie -> General -> Show Loggie Specs** setting to at least **Essential**:

![](assets/screenshots/loggie_specs_essentials.png)

Or if you are [using Custom Settings](docs/customization/CUSTOM_SETTINGS.md), you can set this in the `load()` method instead:

```
show_loggie_specs = LoggieEnums.ShowLoggieSpecsMode.ESSENTIAL
```

#### Related Articles:
👀 **► [Browse All Features](docs/ALL_FEATURES.md)**
📚 ► [Using Custom LoggieSettings](docs/customization/CUSTOM_SETTINGS.md)