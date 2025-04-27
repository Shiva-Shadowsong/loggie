# Custom Settings

Using custom settings is a fantastic way to improve your experience with Loggie in several ways.
Let's review the pros and cons of using custom settings:

### ✔️ Pros
* You get an isolated file where Loggie will read settings from, instead of Project Settings which are stored in `project.godot`.
  Since `project.godot` is a file you basically *must* share with your teammates, it means that whichever settings you choose to use for Loggie, are also enforced to all your teammates. 
  Using a git-ignored `custom_settings.gd` file, each teammate can have their own settings and preferences for Loggie.
  
* Unlocks more flexibility when dealing with Loggie Settings, allowing you to freely and fully customize the values of certain settings without the restrictions of the **Project Settings** window.
  
* Allows customization and access to some settings which are not present in **Loggie Project Settings** at all.
   
### ❌ Cons
* You have to edit a script to change settings instead of using the **Project Settings** window.
* If git-ignored (as suggested), you are responsible for handling how you want to handle backups of this script.
  
## How does it work? 

Loggie, on startup, relies on loading its settings from a script of class `LoggieSettings` .
The default settings script is `loggie_settings.gd`.

Loggie will, before loading the settings from that default script (`loggie_settings.gd`), attempt to look for a script called `custom_settings.gd` in the same folder where `loggie.gd` is located.

This script, if it exists, must be a script that *extends* the `LoggieSettings` class.

If Loggie finds this successfully, it will use it to load the settings instead.

> [!TIP]
> Because that script extends `LoggieSettings`, any setting variable that you don't modify through it will remain at its default value defined in the original LoggieSettings.
> Therefore, you can pick-and-choose what you want to customize, and what you want to leave at default.

## Creating Your Custom Settings Script

It is enough to create a `custom_settings.gd` script in the same directory where `loggie.gd` is located.

```
class_name CustomLoggieSettings extends LoggieSettings

func load():
	# Set values for variables here as you like.
	# For example:
	print_errors_to_console = true
```

> [!NOTE]
> ### Template is available
> In that same directory, you will find a `custom_settings.gd.example` template.
You can rename this to `custom_settings.gd`, change its contents to what you prefer, and it will be good to go.

> [!TIP]
> I recommend that you **gitignore** your `custom_settings.gd` file if you are using Git, so that each of your teammates can have their own `custom_settings.gd` which won't be committed or conflicted with anyone else's - allowing them to have their own Loggie customizations locally.

---
#### Related Articles:
👀 **► [Browse All Features](../ALL_FEATURES.md)**