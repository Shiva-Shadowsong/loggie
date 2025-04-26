# LoggieTools

`LoggieTools` is a class that comes installed with `Loggie`, and is filled with static globally accessible methods that could be useful to you while developing Loggie or even something entirely unrelated.

Here I will only give a brief overview of some of the useful tools, but I encourage you to open the in-engine documentation of the `LoggieTools` class and check out everything that's available:

---
### Named Colors Dictionary
A dictionary that maps the names of every `Color` available in Godot to a `Color` value.

```gdscript
LoggieTools.NamedColors.AQUA # Will be: Color(0, 1, 1, 1)
```

The Godot `Color` class has a bunch of constants bound to it, such as `Color.AQUA` for example.

However, I have found no way to obtain the list of all colors and the names of their constants from this class, so I mapped them out in this dictionary.

Can be useful when working with parsing color names.

---
### String Chunking
Takes a string and cuts it into multiple chunks of the specified length.

```gdscript
chunk_string(string: String, chunk_size: int)
```

---
### Convert To Format
Take a string which is written in a Plain or BBCode format, and convert it into any other [supported format](docs/features/OUTPUT_FORMAT_MODES.md) .

```gdscript
convert_string_to_format_mode(str : String, mode : LoggieEnums.MsgFormatMode)
```

---
### Get Class Name from a Script or Path

Returns the `class_name` from a given `script : Script` or `path : String` .
The parameter `path_or_script` should be either an absolute path to the script 
(e.g. "res://my_script.gd"), or a `Script` object.

`proxy` defines which kind of text will be returned as a replacement for the class name if the script has no `class_name`.

```gdscript
get_class_name_from_script(path_or_script: Variant, proxy: LoggieEnums.NamelessClassExtensionNameProxy)
```

This method is also compatible with older versions of Godot which don't have the `Script.get_global_name` method available *(it was added in some later version)*.

---
#### Related Articles:
👀 **► [Browse All Features](docs/ALL_FEATURES.md)**