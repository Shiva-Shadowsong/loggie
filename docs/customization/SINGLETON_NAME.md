Perhaps you don't like having the autoload singleton of Loggie being called `Loggie`, and you'd prefer something you're more used to, like `log`, `logger`, etc.

You can change the name of the autoload by editing the value of the `loggie_singleton_name` variable in `loggie_settings.gd`.

Your custom name is applied when `Loggie` enters the tree, not when the plugin is enabled / disabled, therefore we need to follow some steps to ensure this process goes smoothly.

#### • Preparation:
> If you already added Loggie to your project or enabled it earlier:
> 
> Ensure that no loggie settings are currently active nor preserved:
> The LoggieSetting "Remove Settings if Plugin Disabled" must be **true**.
> This can be set through **Project Settings -> Loggie -> General**.

#### • Step 1:
> Disable the plugin if it is enabled. 
> 
> This will trigger the plugin to automatically remove whichever autoload it added when it was enabled.
> 
> *If you don't disable the plugin and end up changing the singleton name, make sure to reload the plugin, and also go to Project Settings -> Autoloads, and manually delete the previously created autoload with the old name).*

#### • Step 2:
> Change the value of the `loggie_singleton_name` variable to the desired one.

#### • Step 3:
> If you have any references in your code to the Loggie object via the previously used singleton name, you'll need to update them too.

#### • Step 4:
> Restart Godot.
#### • Step 5:
> Enable the plugin.

> [!CAUTION]
> The `loggie_singleton_name` variable is inside `loggie_settings.gd`, a script that is vulnerable to being overwritten when updating (or auto-updating) to a new version of Loggie.
> 
> Changing this variable's value is considered an advanced customization of the plugin, therefore it is best if you boot your own `custom_settings.gd` to perpetually protect your change, since `custom_settings.gd` is protected from being overwritten during updates.
> 
> [Read how to use Custom Settings here.](CUSTOM_SETTINGS.md)

---
#### Related Articles:
👀 **► [Browse All Features](docs/ALL_FEATURES.md)**
📚 ► [Using Custom LoggieSettings](docs/customization/CUSTOM_SETTINGS.md)