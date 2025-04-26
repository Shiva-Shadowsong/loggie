# Message Output Format Modes

This is a feature that allows you to specify in which format the preprocessor should ultimately send the message to the output channel.

Depending on which type of channel you are using, and which medium you are using to view the logs, you may want to choose a different mode.

This feature is a core component of how Loggie manages to automatically clean up your logs in production/release builds while allowing you to see message styles during development.

> [!IMPORTANT]
> Loggie **expects** that all messages that are coming into the preprocessor **WILL BE** formatted with **BBCode**. Then, it converts them to any other format you choose.
> 
> This is because Godot's terminal uses BBCode for `print_rich`, and we're developing primarily in Godot and using `print_rich` under the hood to output the messages.

### Available Format Modes

#### BBCode

This is the default format in which Loggie expects all messages originally to be in, regardless of what your target output format is.

> [!NOTE]
> If you don't know what BBCode is, it is a lightweight markup language used for styling text. Godot uses and supports this format, mainly through the [**RichTextLabel**](https://docs.godotengine.org/en/latest/tutorials/ui/bbcode_in_richtextlabel.html#bbcode-in-richtextlabel) node and the [print_rich](https://docs.godotengine.org/en/latest/tutorials/ui/bbcode_in_richtextlabel.html#bbcode-in-richtextlabel) function.
> 
> * [What is BBCode](https://en.wikipedia.org/wiki/BBCode)
> * [BBCode in Godot](https://docs.godotengine.org/en/latest/tutorials/ui/bbcode_in_richtextlabel.html#reference)

Use this output format if you are using Godot's console to read the logged output.

While this mode is used, your generated `.log` files may still include unwanted BBCode if proper care is not taken to use only `print_rich` compliant BBCode *(in some versions of Godot)*. 

> By this I mean, for example, you use an unsupported color in your BBCode. Godot's original implementation of `print_rich` only supports a select set of colors which it recognizes and automatically strips the BBCode of. The rest are left untouched.

This is also the fastest mode to use because no conversion needs to happen between the input and the output.

#### ANSI

Use this output format if you intend to view the output in a non-Godot console, such as Powershell, Bash, etc. 

If you are using VSCode or some other external editor to develop your project, use this.
Non-Godot consoles usually rely on ANSI formatting to display colors and other styles.

#### Markdown

Use this output format if you intend to view the entirety of the output in a medium that understands how to read and render the Markdown format.

> [!IMPORTANT]
> Most likely, this will never be your default output format.
> Instead, you may want to manually convert a specific message to this format while developing a custom [channel](docs/features/CHANNELS.md), such as what we did in the `discord` / `slack` channel features.

#### Plain

Use this output format if you want the output to be raw, plain text with no BBCode stylings visible.
This is best used for raw output that needs to be stored into a `.log` file.

> [!IMPORTANT]
> Most likely, you will never use this mode by selecting it manually.
> Instead, Loggie will automatically switch to this mode when it detects that the game is running in a Release build with debug features explicitly disabled.
> 
> This is great because during local development, you can use the fancy modes (BBCode / ANSI), and not have to worry that style tags and weird symbols will appear in your `.log` files on Release.

### Changing the Default Output Format Mode

You can change the default output format in **Project Settings -> Loggie -> General -> Msg Format Mode**.

> I recommend you keep this set to **BBCode** if you are using the Godot Editor for development, or **ANSI** if you are using VSCode / something else.

![](assets/screenshots/msg_format_mode.png)

If you are [using Custom Settings](docs/customization/CUSTOM_SETTINGS.md), you can set this in the `load()` method instead:

```
msg_format_mode = LoggieEnums.MsgFormatMode.BBCODE # Choose the mode you want.
```

---

#### Related Articles:
👀 **► [Browse All Features](docs/ALL_FEATURES.md)**
📚 ► [Channels](docs/features/CHANNELS.md)
📚 ► [Using Custom LoggieSettings](docs/customization/CUSTOM_SETTINGS.md)