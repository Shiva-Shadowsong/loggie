# Message Presets

Message presets allow you to create and save a "template" for a `LoggieMsg` that:

* Has any amount of styles applied to it
* Has any `LoggieMsg` setting / variable set to a desired value (supports **most** of the variables of the `LoggieMsg` class).

And then re-use that template by applying it on any other `LoggieMsg` you create in the future.

Let's see how this works with some examples.
### Creating Presets

To create a new preset, you'll need to give it an `ID` (String).
To use that preset later, you'll need to refer to it by that `ID`.

The method `Loggie.preset(ID)` grabs a `LoggiePreset` with the given `ID` and returns it. 
If it doesn't exist yet, it creates and saves it.

```swift
var preset : LoggiePreset = Loggie.preset("GiantPinkNotification") 
```

### Configuring Presets

Under the hood, a `LoggiePreset` is an extension of the `LoggieMsg` class (which has some minor changes and restrictions).

**Therefore, anything you're used to doing with a `Loggie.msg` - you can do on a `Loggie.preset` to configure it!**

Any modifications you make to a preset will be saved and later re-applied to any other `LoggieMsg` you apply your preset to.

So let's configure our `GiantPinkNotification` preset:

```gdscript
# With one line:
var preset : LoggiePreset = Loggie.preset("GiantPinkNotification").color("pink").bold().italic().suffix("🦩")

# Or with multiple lines - however you prefer.
var preset : LoggiePreset = Loggie.preset("GiantPinkNotification")
preset.color("pink")
preset.bold()
preset.italic()
preset.suffix("🦩")
```

You can create and configure a preset anywhere you want, as long as Loggie is running.
You can do it directly before using it in a script, or you can do it in some autoload or other script that loads at the start of your project.

What else can we do besides styling?
Well, like stated above, anything that you can usually do with a `LoggieMsg`.

In one more example, let's create a preset that, when applied to a message, makes the message use a custom domain, channel and type:

```swift
Loggie.preset("SystemError").color("red").bold().domain("SystemMessages").channel("SystemLogs").type("error")
```

### Applying Presets to Messages

Now that we have a preset, to apply it to any message, we can use the `LoggieMsg.preset` method.

```gdscript
# ----------------------------------------------- #
# Example 1: Apply directly.
# ----------------------------------------------- #

Loggie.msg("Nothin' threatenin' here, I'm just a flamingah!").preset("GiantPinkNotification").info()
```

Results in:

![](https://i.imgur.com/A9kfrZP.png)

```gdscript
# ----------------------------------------------- #
# Example 2: Apply to a previously saved message.
# ----------------------------------------------- #

var kernel_panic_msg = Loggie.msg("KERNEL MIGHT PANIC!")

#... later:
if kernel.is_sweating:
	kernel_panic_msg.preset("SystemError").debug()
```

### Restrictions

>[!IMPORTANT]
>**You shouldn't modify the `preset` in a way that adds new segments to it.**
>Trying to call methods that do this will result in warnings and failure:
>* `preset.msg`
>* `preset.endseg`
>
>You also cannot call `preset.output` or any accompanying wrapper (e.g. `preset.info`, `preset.error`, etc.). 
>Presets are meant to be applied to other messages, not directly get sent to the output.

> There is nothing preventing you from modifying `preset.content` directly, but doing so will likely result in unwanted behavior. Don't do it unless you know exactly what you're doing.

---
#### Related Articles:
👀 **► [Browse All Features](../ALL_FEATURES.md)**

📚 ► [Channels](../features/CHANNELS.md)  
📚 ► [Composing Messages](../features/COMPOSE_AND_OUTPUT_MESSAGES.md)  
📚 ► [Message Types](MESSAGE_TYPES.md)
📚 ► [Domains](../features/DOMAINS.md)