using Godot;
using Godot.Collections;

// ReSharper disable once CheckNamespace
public partial class TestCs : Control
{
    private LoggieSettings _originalSettings;

    public TestCs()
    {
        Loggie.Msg("Test message from TestCs.cs constructor.").Warn();
    }

    public override void _Ready()
    {
        _originalSettings = new LoggieSettings(Loggie.Settings.GodotResource.Duplicate());

        SetupGui();

        PrintSettingValuesFromProjectSettings();
        PrintActualCurrentSettings();

        TestAllLogLevelOutputs();
        TestDomains();
        TestDecors();
        TestSegments();
        TestBbCodeToMarkdown();
        TestDiscordChannel();
    }

    private void SetupGui()
    {
        GetNode<Label>("Label").Text = $"Loggie {Loggie.Version.Major}.{Loggie.Version.Minor}";
        Loggie.Msg("Edit the testcs.tscn _Ready and uncomment the calls to features you want to test out.").Italic()
            .Color(new Color(0.745098f, 0.745098f, 0.745098f)).Preprocessed(false).Info();
    }

    private static void TestAllLogLevelOutputs()
    {
        // Test all types of messages.
        Loggie.Msg("Test logging methods").Box(25).Info();
        Loggie.Msg("Test error.").Error();
        Loggie.Msg("Test warning.").Warn();
        Loggie.Msg("Test notice.").Notice();
        Loggie.Msg("Test info").Info();
        Loggie.Msg("Test", "info", "multi", "argument").Info();
        Loggie.Msg("Test debug message.").Debug();
        GD.Print();

        // Test shortcut wrappers.
        Loggie.Msg("Test logging method wrappers").Box(25).Info();
        Loggie.Error("Error wrapper test.");
        Loggie.Warn("Warn wrapper test.");
        Loggie.Notice("Notice wrapper test.");
        Loggie.Info("Info wrapper test.");
        Loggie.Debug("Debug wrapper test.");
        GD.Print();
    }

    private static void TestDomains()
    {
        Loggie.Msg("Test Domains").Box(25).Info();
        // Test outputting a message from an enabled custom domain.
        Loggie.SetDomainEnabled("Domain1", true);
        Loggie.Msg("> This message is coming from an enabled domain. (You should be seeing this)").Domain("Domain1")
            .Info();

        // Test outputting a message from a disabled domain.
        Loggie.SetDomainEnabled("Domain1", false);
        Loggie.Msg("Another similar message should appear below this notice if something is broken.").Italic()
            .Color(new Color(0.411765f, 0.411765f, 0.411765f)).Notice();
        Loggie.Msg("> This message is coming from a disabled domain (You shouldn't be seeing this).").Domain("Domain1")
            .Error();

        // Test outputting a message from a domain that is configured to use custom channels.
        Loggie.SetDomainEnabled("Domain3", true, "discord");
        Loggie.Msg("> This message should be visible on discord. (You should be seeing this)").Domain("Domain3").Info();
        Loggie.SetDomainEnabled("Domain4", true,
            new Array
            {
                "discord", 53, new Color(1f, 0, 0), "terminal"
            }); // Purposefully provide a partially incorrect value to test error handling.
        Loggie.Msg("> This message should be visible on discord and terminal. (You should be seeing this)")
            .Domain("Domain4").Info();
    }

    private static void TestDecors()
    {
        Loggie.Msg("Test Decorations").Box(25).Info();

        // Test outputting a box header.
        Loggie.Msg("Box Header Test").Color("red").Box().Info();

        // Test outputting a header, with a newline and a 30 character long horizontal separator.
        Loggie.Msg("Colored Header").Header().Color("yellow").Nl().HSeparator(30).Info();

        // Test a supported color message of all types.
        Loggie.Msg("Supported color info.").Color("cyan").Info();
        Loggie.Msg("Supported color notice.").Color("cyan").Notice();
        Loggie.Msg("Supported color warning.").Color("cyan").Warn();
        Loggie.Msg("Supported color error.").Color("cyan").Error();
        Loggie.Msg("Supported color debug.").Color("cyan").Debug();

        // Test a custom colored message.
        // (Arbitrary hex codes).
        Loggie.Msg("Custom colored info msg.").Color("#3afabc").Info();
        Loggie.Msg("Custom colored notice.").Color("#3afabc").Notice();
        Loggie.Msg("Custom colored warning.").Color("#3afabc").Warn();
        Loggie.Msg("Custom colored error.").Color("#3afabc").Error();
        Loggie.Msg("Custom colored debug.").Color("#3afabc").Debug();

        // Test pretty printing a dictionary.
        var testDict = new Dictionary
        {
            { "a", "Hello" },
            {
                "b", new Dictionary
                {
                    { "c", 1 },
                    {
                        "d", new Array
                        {
                            1, 2, 3,
                        }
                    }
                }
            },
            { "c", new Array { "A", new Dictionary { { "B", "2" } }, 3 } }
        };
        Loggie.Msg(testDict).Info();
    }

    private static void TestSegments()
    {
        // Test basic segmenting.
        var msg = Loggie.Msg("Segment 1 *").EndSeg().Add(" Segment 2 *").EndSeg().Add(" Segment 3").Info();

        // Print the 2nd segment of that segmented message:
        Loggie.Info("Segment 1 is:", msg.String(1));

        // Test messages where each segment has different styles.
        Loggie.Msg("SegmentKey:").Bold().Color("orange").Msg("SegmentValue").Color("dim gray").Info();
        Loggie.Msg("SegHeader").Header().Color("orange").Space().Msg("SegPlain ").Msg("SegGrayItalic").Italic()
            .Color("dim gray").Prefix("PREFIX: ").Suffix(" - SUFFIX").Debug();

        GD.Print("\n\n");
        Loggie.Msg("Segment1: ").Color("orange").Msg("Segment2").Info();
    }

    private static void TestBbCodeToMarkdown()
    {
        var msg = Loggie.Msg("Hello world").Italic().Color(new Color(1f, 0, 0)).Msg(" - part 2 is bold").Bold();
        GD.Print($"Text to convert:\n{msg.String()}");
    }

    private static void TestDiscordChannel()
    {
        // Standard test with decorations.
        Loggie.Msg("Hello world").Italic().Msg(" - from Godot!").Bold().Channel("discord").Info();

        // Test long message.
        var msg2KLong =
            "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc, quis gravida magna mi a libero. Fusce vulputate eleifend sapien. Vestibulum purus quam, scelerisque ut, mollis sed, nonummy id, metus. Nullam accumsan lorem in dui. Cras ultricies mi eu turpis hendrerit fringilla. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; In ac dui quis mi consectetuer lacinia. Nam pretium turpis et arcu. Duis arcu tortor, suscipit eget, imperdiet nec, imperdiet iaculis, ipsum. Sed aliquam ultrices mauris. Integer ante arcu, accumsan a, consectetuer eget, posuere ut, mauris. Praesent adipiscing. Phasellus ullamcorper ipsum rutrum nunc. Nunc nonummy metus. Vestibzzz";
        Loggie.Msg(msg2KLong, msg2KLong).Channel("discord").Info();
    }

    private static void TestSlackChannel()
    {
        // Standard test with decorations.
        Loggie.Msg("Hello world").Italic().Msg(" - from Godot!").Bold().Channel("slack").Info();

        // Test long message.
        var msg2KLong =
            "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc, quis gravida magna mi a libero. Fusce vulputate eleifend sapien. Vestibulum purus quam, scelerisque ut, mollis sed, nonummy id, metus. Nullam accumsan lorem in dui. Cras ultricies mi eu turpis hendrerit fringilla. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; In ac dui quis mi consectetuer lacinia. Nam pretium turpis et arcu. Duis arcu tortor, suscipit eget, imperdiet nec, imperdiet iaculis, ipsum. Sed aliquam ultrices mauris. Integer ante arcu, accumsan a, consectetuer eget, posuere ut, mauris. Praesent adipiscing. Phasellus ullamcorper ipsum rutrum nunc. Nunc nonummy metus. Vestibzzz";
        Loggie.Msg(msg2KLong, msg2KLong).Channel("slack").Info();
    }

    private static void PrintSettingValuesFromProjectSettings()
    {
        Loggie.Msg("Loggie Settings (as read from Project Settings):").Header().Info();
        foreach (var (key, value) in Loggie.Settings.ProjectSettings)
        {
            Loggie.Msg($"|\t{key} = {value}").Info();
        }

        GD.Print();
    }

    private static void PrintActualCurrentSettings()
    {
        Loggie.Msg("Loggie Settings (as read from Loggie.settings):").Header().Info();
        var settingsDict = Loggie.Settings.ToDict();
        Loggie.Msg(settingsDict).Info();
        GD.Print();
    }


    private void ResetSettings()
    {
        Loggie.Settings = new LoggieSettings(_originalSettings.GodotResource.Duplicate());
    }
}