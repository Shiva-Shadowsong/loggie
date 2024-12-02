
The aim of this guide is to teach you all the basic ways you can use Loggie to compose and stylize messages. Let's begin.

# Quick Output

If you have no desire to stylize your message and simply want to output at a log level quickly, you can use the shortcut functions:

```swift
Loggie.error("Message")

Loggie.warn("Hello")

Loggie.notice("Hello")

Loggie.info("Hello")

Loggie.debug("Hello")
```


<details>
  <summary>
	  <b>What's the difference between these?</b> <i style="font-size:12px; color:orange;">(Click to show)</i>
  </summary>
<p>Each of these methods output the same message, but at a different Log Level. There are 5 log levels, in ascending order: <i>Error (0), Warn (1), Notice (2), Info (3), Debug (4)</i>.
<br>Messages that are output on a level that's higher than the currently applied `Log Level` setting will not be pre-processed or logged.</p><p>That allows you to control in which environment certain messages should be logged.</p><p>For example, while you are developing, you may want to see all messages including 'Debug' ones - but don't want your users to see this if they run your released application.</p><p>Good news! You don't need to go and delete all your log lines throughout your codebase. Simply ensure that undesired levels are turned off in Loggie settings.</p> 
</details>

---
# Composing Messages

### Creating and Logging a "LoggieMsg"
All messages Loggie works with are instances of `LoggieMsg`, a string wrapper class that comes along with a bunch of extra utilities. These are the messages we'll be outputting.

To create a `LoggieMsg` and fill it with some starting content, we should use the `Loggie.msg(...)` method:

```gdscript
Loggie.msg("Hello world.")
```

This method actually returns the `LoggieMsg` that was created, so you can store it in a variable and keep it alive for a while as you keep modifying it:

```gdscript
var msg = Loggie.msg("You look in the mirror. You see ")

## later on...
if creature.type == Types.Dog:
	msg.add("a goodest boy.")
else:
	msg.add("an incredible game developer.")
```


One cool thing about all of these methods, is that they all return back the same message you just modified. Which means we can chain them together as much as we want:

```gdscript
Loggie.msg("You").add("spin me").add("right round").add("baby").add("🎶🥁🎶")
# Your tech lead might choke you out if they find emojis in the logs.
```


When you are ready to output the message, call one of the output methods on it. There is one method for each log level:

```gdscript
msg.error()   msg.warn()   msg.notice()   msg.info()   msg.debug()
```

### Concatenating Content
Did you notice something up there? The method `add` was used to add more content to an existing message. There are many ways to fill up your message with multiple instances of concatenated data.
Let's check that out:

```gdscript
# In a single 'msg' call:
var msg = Loggie.msg("You", "can", "use", "six", "parameters", "max")

# Need more? Let's "add" more:
msg.add("we", "could", "really", "go", "on", "endlessly")

# What about some other types of data? ...
```

##### Different Types of Data in a Message
We are not limited to only concatenating strings. You can add **anything** into your message!
<span style="color:gray;font-weight: bold;font-size:7px">Just not emojis. I told you, you'll be put on a damn watchlist.</span>

```gdscript
var creature = load("res://Creature.tscn").instantiate()
var attributes = ["easy", "lovely", "the BEST", "exceptionally humble"]
var body = {
	"text" : "Loggie",
	"bulging_eyes" : 2,
	"color" : Color("#e0a944"),
}
var finalRemarkMsg = Loggie.msg("What a specimen.")

Loggie.msg("We have a", creature, "with attrs:", attributes, "and body:", body, finalRemarkMsg).info()
```

Result:

![](https://i.imgur.com/XCsQHe0.png)

As a keen observer, you'll notice that we can even merge one  `LoggieMsg`  into another.
Let's make this spicier.


### Styling Messages

![https://i.imgur.com/kTLhmjK.png](https://i.imgur.com/kTLhmjK.png)

Log browsability and readability is at the forefront of what Loggie sets out to achieve. 
And what better way to do that, than with various styles and colors that clearly separate, highlight and outline certain messages?


We can chain various LoggieMsg methods onto the message to apply one or multiple styles.
For example:

```gdscript
# Make a box with 30 horizontal padding and blue text inside.
var title = Loggie.msg("Conversation Log:").color(Color.SLATE_BLUE).box(30)
title.preprocessed(false)
title.info()

# Make stylized messages. Easy to imagine what they might look like?
Loggie.msg("Bye Loggie!").bold().info()
Loggie.msg("Cache you later!").prefix("👀").color("orange").italic().info()
```

Here is a list of all styling functions you can use.

 **🗒️ Note:**
> This may not always be up to date. An up-to-date list and documentation of all methods available for modifying a `LoggieMsg` can always be found in the `LoggieMsg` class documentation. 
> Godot Top Bar -> 'Script'  -> 'Search Help' (top right corner) -> 'LoggieMsg'.

❗ **Warning:**

> Unless documentation indicates otherwise, all modifications by these methods are done to the **current content** of the message, and won't apply to any additional content that is appended to that same message afterwards.

------------

##### bold()
> Makes the current segment of this message bold.

```gdscript
Loggie.msg("I'm bold.").bold().info()
```
![](https://i.imgur.com/JL5vjlt.png)

------------

##### italic()
> Makes the current segment of this message italic.

```gdscript
Loggie.msg("I'm italic.").italic().info()
```
![](https://i.imgur.com/omvar4a.png)

------------

##### header()
> Stylizes the current segment of this message as a header.
> You can adjust how this appears in the `format_header` setting.
> Headers are by default "bold + italic".

```gdscript
Loggie.msg("This is a header.").header().info()
```
 ![](https://i.imgur.com/MJq1zDs.png)

------------

##### color(color : String | Color)
> Wraps the current segment of this message in the given color. The color can be provided as a Color, a recognized Godot color name (String, e.g. "red"), or a color hex code (String, e.g. "#ff0000").

```gdscript
Loggie.msg("Hello.").color(Color.RED).info()
Loggie.msg("Hello.").color("#ff0000").info()
```
![](https://i.imgur.com/CzVnNxs.png)

❗ **Warning:**

> Loggie uses `print_rich` under the hood to print stylized messages. Unfortunately, as of right now, Godot's BBCode color parser for that function only officially supports a small sub-set of colors in full.
> 
> If you are using `TerminalMode.BBCODE` and use an unsupported color - your logs **WILL NOT** end up having the BBCode of that color stripped from them. This is not a concern for Release/Production builds because Loggie automatically uses `TerminalMode.PLAIN` in that circumstance - which strips *all* BBCode.
> The list of supported colors can be found in the documentation of the `print_rich` method - `black, red, green, yellow, blue, magenta, pink, purple, cyan, white, orange, gray`


------------

##### nl(amount: int = 1)
> Adds the specified amount of newline characters to the end of the current segment.

```gdscript
Loggie.msg("New line after me.").nl().info()
```

------------

##### tab(amount: int = 1)
> Adds the specified amount of tab characters to the end of the current segment.

```gdscript
# Add 2 tabs between these 2 words.
Loggie.msg("Left").tab(2).add("Right").info()
```

------------

##### space(amount: int = 1)
> Adds the specified amount of space characters to the end of the current segment.

```gdscript
# Add 10 spaces between these 2 words.
Loggie.msg("Left").space(10).add("Right").info()
```

------------
##### box(h_padding: int = 4)
> Constructs a decorative box with the given horizontal padding around the current segment of this message. Messages containing a box are not going to be preprocessed, so they are best used only as a special header or decoration.

> You can adjust how the box is constructed in the `box_symbols_compatible` and `box_symbols_pretty` advanced setting.

> You can choose which box type to use with the Loggie Project Settings -> Preprocessing -> Box Characters Mode setting.

```gdscript
Loggie.msg("Let me oooout.").box(6).info()
```
![](https://i.imgur.com/sjiVW1g.png)

------------
##### hseparator(size: int = 16, alternative_symbol: Variant = null)
> Appends a horizontal separator with the given length to the message. If alternative_symbol is provided, it should be a String, and it will be used as the symbol for the separator instead of the default one.

```gdscript
# Adds a new line 
Loggie.msg("Very important business.").header().nl().hseparator(20).info()
```
![](https://i.imgur.com/mTEmPgw.png)

------------

##### add(...)
> Converts the provided arguments to strings and appends them to the end of the current content.
> If an argument is a Dictionary, it will be converted with the pretty-print format. If an argument is LoggieMsg, that message's content will be merged into this message's content.

```gdscript
# Basic usecase
Loggie.msg("Hello ").add("World").info()

# Merging messages
var msg1 = Loggie.msg("Hello").bold()
var msg2 = Loggie.msg("World").color("yellow")
msg1.add(msg2).info()
```

------------

##### prefix(prefix : String, separator : String = "")
> Prepends the given prefix string to the start of the whole message (first segment) with the provided separator.

```gdscript
Loggie.msg("After").prefix("Before").info()
```

------------

##### suffix(suffix : String, separator : String = "")
> Appends the given suffix string to the end of the message (last segment) with the provided separator.

```gdscript
Loggie.msg("Before").suffix("After").info()
```

### Segmenting Messages

Sometimes, you may want to stylize individual parts of a complex message differently.
For example, if printing a key and value - you may want to have one style for the key, and a different one for the value, like so:

![](https://i.imgur.com/SR6rzkr.png)

For this purpose, we can segment this single message into individual parts, and apply styles independently to each segment.

Whenever you create a `LoggieMsg`, you are automatically creating its first segment.

```gdscript
## Creates a message with one segment and stylizes it.
Loggie.msg("SegmentKey").bold().color(Color.ORANGE)
```

Now we can use the function `endseg` to end that segment, and begin a new one. If we apply any stylings - they will only be applied to the newest segment.

```gdscript
Loggie.msg("SegmentKey").bold().endseg().add("SegmentValue")
```

There, we ended the first segment (and thereby started the next one), and added "SegmentValue" in the next segment. Now if we do

```gdscript
Loggie.msg("SegmentKey").bold().endseg().add("SegmentValue").italic()
```

Only the "SegmentValue" part of the string will be italic.

There is a shortcut for `endseg() + add()`, which is just calling `msg` again. So, instead of the above, we can write:

```gdscript
Loggie.msg("SegmentKey").bold().msg("SegmentValue").italic()
```

This keeps it shorter and more in line with what you're used to writing (`msg`).

---

# 🎉 Congratulations! 🥳 

You're now a certified pro at styling with Loggie!
If you have any suggestions or feature requests to make this experience even more awesome, please share them on the Loggie Discord, or open a feature proposal issue on GitHub.

[<img src="https://i.imgur.com/QyOsL16.png">](https://discord.gg/XPdxpMqmcs)