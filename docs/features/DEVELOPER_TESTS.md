>[!INFO]
>This section is only concerning the developers of the Loggie plugin, not the end-users of the plugin, as the code/features discussed here are not shipped when you just import the addon instead of the whole Loggie project.

Loggie now comes equipped with better testing tools, using a mix of automated tests and visual tests, to help Loggie developers make changes with more confidence that none of the key functionalities are broken.

Of course, the coverage is not complete, and the addon could break in many other ways that are not covered by these tests, but as long as all of the pre-configured tests are passing, you can at least be sure that the majority of the key functionalities remain in a healthy state.

You should, of course, test your changes in whichever way you can, including but not limited to - writing your own Test Case for the changes being tested.

## How does it work?

Simply run the Loggie project (F5) and the main scene - the testing module - should open up. 
There, press the `Begin Testing` button.

![img](https://i.imgur.com/lnkNwQX.png)

First, automatic tests will run.
Just let it finish and observe the results.
If all tests have passed - good, if not, both the UI and the console will let you know why.

>[!INFO]
>In your main console, you can find a more verbose output of each test, detailing exactly what's going on.


![](https://i.imgur.com/BUM2TLd.png)

Once this is done, click `Proceed to Visual Tests` on the bottom.

Now you will begin a series of tests that should be verified manually by looking at them and either Accepting or Rejecting the result.

Simply follow the instructions and mark each test with either of the possible answers to complete the testing.

![](https://i.imgur.com/RL4IH8n.png)

In the end, you will see either a success message:

![](https://i.imgur.com/1DHEhRZ.png)

Or a failure message:

![](https://i.imgur.com/MrZtIhp.png)

instructing you how to proceed.

The tests can be found in `project_directory/test/test_cases/` should you need to go in there and verify something yourself.

## Creating Your Own Tests

To create your own test, first decide whether you want to make an automated or a visual test, then follow the instructions below.
### Creating Automated Tests

First, create a new script in `project_directory/test/test_cases/automatic/`.

```swift
class_name MyTestName extends LoggieAutoTestCase

func run() -> void:
	# Your test logic goes here.
	pass
```

You define an override for the `run()` method, and in it, do whatever you need to.

While this function runs, you also have access to the `settings` variable which is a reference to a custom set of `LoggieSettings` which are applied to `Loggie` while your test is running.

Therefore, during your test, you may modify the loggie settings however you like, and once your test is finished, they will return back to their original settings automatically.

>[!IMPORTANT]
>For your test to conclude successfully, it either has to call the `success()` or `fail()` method somewhere within `run()`, so make sure to call those at the appropriate time.

You can have a look at the other tests to see some practical examples of automated tests.
#### Registering an Automated Test

Once your test is ready, you need to register it so it can run.
You can do that by doing the following.
Open the `test.tscn` scene and look for the `Tests/Automated/AutoTestCases` node.

![](https://i.imgur.com/irruVBQ.png)

Inside of it, create a new `Node` and attach your test's script to it.
That's it.

If you need to temporarily disable some of the tests, move them to the `DisabledAutoTestCases` node.

### Creating Visual Tests

First, create a new script in `project_directory/test/test_cases/visual/`.

```swift
class_name VMyTestName extends LoggieVisualTestCase

func _init() -> void:
	title = "My Test Name"

func run() -> void:
	# Your test logic goes here.
```

The class names of visual tests usually have a `V` prefix.

In the `_init` method , you can set the value of the `title` variable, which will be displayed in the testing UI.

You define an override for the `run()` method, and in it, define whatever your test needs to display in the app UI.

You have access to the console UI through the `_console` variable of your test.
Two helper methods have been added to let you quickly add text or any arbitrary node to the console:

```swift
## Add some text (bbcode supported):
_console.add_text("hello")

## Add any other node:
var custom_node = Control.new()
_console.add_content(custom_node)
```

Additionally, while your test runs, you can also modify `Loggie.settings` safely, and your changes will be reverted automatically once your test is done running.

Your tests state will be marked as `Accepted` or `Rejected` by the buttons in the user interface with which the user is prompted to confirm the results, therefore, this type of test has no `success()` or `fail()` method, as opposed to the automated ones.

#### Registering a Visual Test

Once your test is ready, you need to register it so it can run.
You can do that by doing the following.
Open the `test.tscn` scene and look for the `Tests/Visual/VisualTestCases` node.

![](https://i.imgur.com/CFH6Ry9.png)

Inside of it, create a new `Node` and attach your test's script to it.
That's it.

If you need to temporarily disable some of the tests, move them to the `DisabledVisualTestCases` node.

---
### For Both Types of Tests

Furthermore, there is a helpful blank Channel called `test_channel` that can be helpful while testing.
The goal of this channel is to receive messages like any other channel, except it doesn't do anything with those messages.
It only emits a signal `message_received(msg : LoggieMsg, type : LoggieEnums.MsgType)` once a message arrives to this channel successfully.
You can use it to test how messages will look when they arrive at their desired channels after they go through all the internal phases of preprocessing and other checks.

You can access the channel like so:
```swift
var test_channel : LoggieMsgChannel = Loggie.get_channel("test_channel")
test_channel.preprocess_flags = LoggieEnums.PreprocessStep.APPEND_TIMESTAMPS # Set custom preprocess flags? 
```

---
#### Related Articles:
👀 **► [Browse All Features](../ALL_FEATURES.md)**  
📚 ► [Channels](CHANNELS.md) 