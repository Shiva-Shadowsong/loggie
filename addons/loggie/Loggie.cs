using Godot;

#nullable disable

// ReSharper disable once CheckNamespace
public class Loggie
{
    // TODO: support other singleton names
    private static readonly NodePath NodePath = new("/root/Loggie");
    private readonly Node _loggie;

    public LoggieVersion Version
    {
        get => new LoggieVersion(_loggie.Get(ClassVariable.Version).AsGodotObject());
        set => _loggie.Set(ClassVariable.Version, value.GodotObject);
    }

    public LoggieSettings Settings
    {
        get => new LoggieSettings(_loggie.Get(ClassVariable.Settings).AsGodotObject());
        set => _loggie.Set(ClassVariable.Version, value.GodotObject);
    }

    public Godot.Collections.Dictionary Domains
    {
        get => _loggie.Get(ClassVariable.Domains).AsGodotDictionary();
        set => _loggie.Set(ClassVariable.Domains, value);
    }

    public Godot.Collections.Dictionary ClassNames
    {
        get => _loggie.Get(ClassVariable.ClassNames).AsGodotDictionary();
        set => _loggie.Set(ClassVariable.ClassNames, value);
    }

    public Godot.Collections.Dictionary AvailableChannels
    {
        get => _loggie.Get(ClassVariable.AvailableChannels).AsGodotDictionary();
        set => _loggie.Set(ClassVariable.AvailableChannels, value);
    }

    public Loggie()
    {
        var sceneTree = (SceneTree)Engine.GetMainLoop();
        _loggie = sceneTree.Root.GetNode(NodePath);

        if (_loggie == null)
        {
            GD.PrintErr($"Could not find loggie plugin at: {NodePath}");
        }
    }

    public bool LoadSettingsFromPath(string path)
    {
        return _loggie.Call(MethodName.LoadSettingsFromPath, path).AsBool();
    }

    public bool IsInProduction()
    {
        return _loggie.Call(MethodName.IsInProduction).AsBool();
    }

    public Godot.Collections.Array GetDomainCustomTargetChannels(string domainName)
    {
        return _loggie.Call(MethodName.GetDomainCustomTargetChannels, domainName).AsGodotArray();
    }

    public void SetDomainEnabled(string domainName, bool enabled, Variant customTargetChannels = new())
    {
        _loggie.Call(MethodName.SetDomainEnabled, domainName, enabled, customTargetChannels);
    }

    public bool IsDomainEnabled(string domainName)
    {
        return _loggie.Call(MethodName.IsDomainEnabled, domainName).AsBool();
    }

    public bool GetChannel(string channelId)
    {
        return _loggie.Call(MethodName.GetChannel, channelId).AsBool();
    }

    public void AddChannel(LoggieMsgChannel loggieMsgChannel)
    {
        _loggie.Call(MethodName.AddChannel, loggieMsgChannel.GodotObject);
    }

    public LoggieMsg Msg(Variant? message = null, Variant? arg1 = null, Variant? arg2 = null, Variant? arg3 = null,
        Variant? arg4 = null, Variant? arg5 = null)
    {
        return new LoggieMsg(_loggie.Call(MethodName.Msg,
            message ?? new Variant(),
            arg1 ?? new Variant(),
            arg2 ?? new Variant(),
            arg3 ?? new Variant(),
            arg4 ?? new Variant(),
            arg5 ?? new Variant()).AsGodotObject());
    }

    public LoggieMsg Info(Variant? message = null, Variant? arg1 = null, Variant? arg2 = null, Variant? arg3 = null,
        Variant? arg4 = null, Variant? arg5 = null)
    {
        return new LoggieMsg(_loggie.Call(MethodName.Info,
            message ?? new Variant(),
            arg1 ?? new Variant(),
            arg2 ?? new Variant(),
            arg3 ?? new Variant(),
            arg4 ?? new Variant(),
            arg5 ?? new Variant()).AsGodotObject());
    }

    public LoggieMsg Warn(Variant? message = null, Variant? arg1 = null, Variant? arg2 = null, Variant? arg3 = null,
        Variant? arg4 = null, Variant? arg5 = null)
    {
        return new LoggieMsg(_loggie.Call(MethodName.Warn,
            message ?? new Variant(),
            arg1 ?? new Variant(),
            arg2 ?? new Variant(),
            arg3 ?? new Variant(),
            arg4 ?? new Variant(),
            arg5 ?? new Variant()).AsGodotObject());
    }

    public LoggieMsg Error(Variant? message = null, Variant? arg1 = null, Variant? arg2 = null, Variant? arg3 = null,
        Variant? arg4 = null, Variant? arg5 = null)
    {
        return new LoggieMsg(_loggie.Call(MethodName.Error,
            message ?? new Variant(),
            arg1 ?? new Variant(),
            arg2 ?? new Variant(),
            arg3 ?? new Variant(),
            arg4 ?? new Variant(),
            arg5 ?? new Variant()).AsGodotObject());
    }

    public LoggieMsg Debug(Variant? message = null, Variant? arg1 = null, Variant? arg2 = null, Variant? arg3 = null,
        Variant? arg4 = null, Variant? arg5 = null)
    {
        return new LoggieMsg(_loggie.Call(MethodName.Debug,
            message ?? new Variant(),
            arg1 ?? new Variant(),
            arg2 ?? new Variant(),
            arg3 ?? new Variant(),
            arg4 ?? new Variant(),
            arg5 ?? new Variant()).AsGodotObject());
    }

    public LoggieMsg Notice(Variant? message = null, Variant? arg1 = null, Variant? arg2 = null, Variant? arg3 = null,
        Variant? arg4 = null, Variant? arg5 = null)
    {
        return new LoggieMsg(_loggie.Call(MethodName.Notice,
            message ?? new Variant(),
            arg1 ?? new Variant(),
            arg2 ?? new Variant(),
            arg3 ?? new Variant(),
            arg4 ?? new Variant(),
            arg5 ?? new Variant()).AsGodotObject());
    }

    public string GetDirectoryPath()
    {
        return _loggie.Call(MethodName.GetDirectoryPath).AsString();
    }

    public LoggieMsg Stack()
    {
        return new LoggieMsg(_loggie.Call(MethodName.Stack).AsGodotObject());
    }

    private static class ClassVariable
    {
        public static readonly StringName Version = "version";
        public static readonly StringName Settings = "settings";
        public static readonly StringName Domains = "domains";
        public static readonly StringName ClassNames = "class_names";

        public static readonly StringName AvailableChannels = "available_channels";
        // not implemented 
        // public static readonly StringName VersionManager = "version_manager";
    }

    private static class MethodName
    {
        public static readonly StringName LoadSettingsFromPath = "load_settings_from_path";
        public static readonly StringName IsInProduction = "is_in_production";
        public static readonly StringName GetDomainCustomTargetChannels = "get_domain_custom_target_channels";
        public static readonly StringName SetDomainEnabled = "set_domain_enabled";
        public static readonly StringName IsDomainEnabled = "is_domain_enabled";
        public static readonly StringName GetChannel = "get_channel";
        public static readonly StringName AddChannel = "add_channel";
        public static readonly StringName Msg = "msg";
        public static readonly StringName Info = "info";
        public static readonly StringName Warn = "warn";
        public static readonly StringName Error = "error";
        public static readonly StringName Debug = "debug";
        public static readonly StringName Notice = "notice";
        public static readonly StringName GetDirectoryPath = "GetDirectoryPath";
        public static readonly StringName Stack = "stack";
    }
}

public class LoggieVersion(GodotObject godotObject)
{
    public readonly GodotObject GodotObject = godotObject;

    public int Minor
    {
        get => GodotObject.Get(ClassVariable.Minor).AsInt32();
        set => GodotObject.Set(ClassVariable.Minor, value);
    }

    public int Major
    {
        get => GodotObject.Get(ClassVariable.Major).AsInt32();
        set => GodotObject.Set(ClassVariable.Major, value);
    }

    public LoggieVersion ProxyFor
    {
        get => new LoggieVersion(GodotObject.Get(ClassVariable.ProxyFor).AsGodotObject());
        set => GodotObject.Set(ClassVariable.ProxyFor, value.GodotObject);
    }

    public bool IsValid()
    {
        return GodotObject.Call(MethodName.IsValid).AsBool();
    }

    public bool IsHigherThan()
    {
        return GodotObject.Call(MethodName.IsHigherThan).AsBool();
    }

    public LoggieVersion FromString(string versionString)
    {
        return new LoggieVersion(GodotObject.Call(MethodName.FromString, versionString).AsGodotObject());
    }

    private static class ClassVariable
    {
        public static readonly StringName Minor = "minor";
        public static readonly StringName Major = "major";
        public static readonly StringName ProxyFor = "proxy_for";
    }

    private static class MethodName
    {
        public static readonly StringName IsValid = "is_valid";
        public static readonly StringName IsHigherThan = "is_higher_than";
        public static readonly StringName FromString = "from_string";
    }
}

public class LoggieSettings(GodotObject godotObject)
{
    public readonly GodotObject GodotObject = godotObject;

    public Godot.Collections.Dictionary ProjectSettings
    {
        get => GodotObject.Get(ClassVariable.ProjectSettings).AsGodotDictionary();
        set => GodotObject.Set(ClassVariable.ProjectSettings, value);
    }

    public LoggieEnums.UpdateCheckType UpdateCheckMode
    {
        get => GodotObject.Get(ClassVariable.UpdateCheckMode).As<LoggieEnums.UpdateCheckType>();
        set => GodotObject.Set(ClassVariable.ProjectSettings, (int)value);
    }

    public LoggieEnums.MsgFormatMode MsgFormatMode
    {
        get => GodotObject.Get(ClassVariable.MsgFormatMode).As<LoggieEnums.MsgFormatMode>();
        set => GodotObject.Set(ClassVariable.MsgFormatMode, (int)value);
    }

    public LoggieEnums.LogLevel LogLevel
    {
        get => GodotObject.Get(ClassVariable.LogLevel).As<LoggieEnums.LogLevel>();
        set => GodotObject.Set(ClassVariable.LogLevel, (int)value);
    }

    public LoggieEnums.ShowLoggieSpecsMode ShowLoggieSpecs
    {
        get => GodotObject.Get(ClassVariable.ShowLoggieSpecs).As<LoggieEnums.ShowLoggieSpecsMode>();
        set => GodotObject.Set(ClassVariable.ShowLoggieSpecs, (int)value);
    }

    public bool ShowSystemSpecs
    {
        get => GodotObject.Get(ClassVariable.ShowSystemSpecs).AsBool();
        set => GodotObject.Set(ClassVariable.ShowLoggieSpecs, value);
    }

    public bool PrintErrorsToConsole
    {
        get => GodotObject.Get(ClassVariable.PrintErrorsToConsole).AsBool();
        set => GodotObject.Set(ClassVariable.PrintErrorsToConsole, value);
    }

    public bool PrintWarningsToConsole
    {
        get => GodotObject.Get(ClassVariable.PrintWarningsToConsole).AsBool();
        set => GodotObject.Set(ClassVariable.PrintWarningsToConsole, value);
    }

    public LoggieEnums.NamelessClassExtensionNameProxy NamelessClassNameProxy
    {
        get => GodotObject.Get(ClassVariable.NamelessClassNameProxy).As<LoggieEnums.NamelessClassExtensionNameProxy>();
        set => GodotObject.Set(ClassVariable.NamelessClassNameProxy, (int)value);
    }

    public bool TimestampsUseUtc
    {
        get => GodotObject.Get(ClassVariable.TimestampsUseUtc).AsBool();
        set => GodotObject.Set(ClassVariable.TimestampsUseUtc, value);
    }

    public bool DebugMsgsPrintStackTrace
    {
        get => GodotObject.Get(ClassVariable.DebugMsgsPrintStackTrace).AsBool();
        set => GodotObject.Set(ClassVariable.DebugMsgsPrintStackTrace, value);
    }

    public bool EnforceOptimalSettingsInReleaseBuild
    {
        get => GodotObject.Get(ClassVariable.EnforceOptimalSettingsInReleaseBuild).AsBool();
        set => GodotObject.Set(ClassVariable.EnforceOptimalSettingsInReleaseBuild, value);
    }

    public string DiscordWebhookUrlDev
    {
        get => GodotObject.Get(ClassVariable.DiscordWebhookUrlDev).AsString();
        set => GodotObject.Set(ClassVariable.DiscordWebhookUrlDev, value);
    }

    public string DiscordWebhookUrlLive
    {
        get => GodotObject.Get(ClassVariable.DiscordWebhookUrlLive).AsString();
        set => GodotObject.Set(ClassVariable.DiscordWebhookUrlLive, value);
    }

    public string SlackWebhookUrlDev
    {
        get => GodotObject.Get(ClassVariable.SlackWebhookUrlDev).AsString();
        set => GodotObject.Set(ClassVariable.SlackWebhookUrlDev, value);
    }

    public string SlackWebhookUrlLive
    {
        get => GodotObject.Get(ClassVariable.SlackWebhookUrlLive).AsString();
        set => GodotObject.Set(ClassVariable.SlackWebhookUrlLive, value);
    }

    public int PreprocessFlagsTerminalChannel
    {
        get => GodotObject.Get(ClassVariable.PreprocessFlagsTerminalChannel).AsInt32();
        set => GodotObject.Set(ClassVariable.PreprocessFlagsTerminalChannel, value);
    }

    public int PreprocessFlagsDiscordChannel
    {
        get => GodotObject.Get(ClassVariable.PreprocessFlagsDiscordChannel).AsInt32();
        set => GodotObject.Set(ClassVariable.PreprocessFlagsDiscordChannel, value);
    }

    public int PreprocessFlagsSlackChannel
    {
        get => GodotObject.Get(ClassVariable.PreprocessFlagsSlackChannel).AsInt32();
        set => GodotObject.Set(ClassVariable.PreprocessFlagsSlackChannel, value);
    }

    public Godot.Collections.Array DefaultChannels
    {
        get => GodotObject.Get(ClassVariable.DefaultChannels).AsGodotArray();
        set => GodotObject.Set(ClassVariable.DefaultChannels, value);
    }

    public Godot.Collections.Array SkippedFilenamesInStackTrace
    {
        get => GodotObject.Get(ClassVariable.SkippedFilenamesInStackTrace).AsGodotArray();
        set => GodotObject.Set(ClassVariable.SkippedFilenamesInStackTrace, value);
    }

    public string FormatHeader
    {
        get => GodotObject.Get(ClassVariable.FormatHeader).AsString();
        set => GodotObject.Set(ClassVariable.FormatHeader, value);
    }

    public string FormatDomainPrefix
    {
        get => GodotObject.Get(ClassVariable.FormatDomainPrefix).AsString();
        set => GodotObject.Set(ClassVariable.FormatDomainPrefix, value);
    }

    public string FormatErrorMsg
    {
        get => GodotObject.Get(ClassVariable.FormatErrorMsg).AsString();
        set => GodotObject.Set(ClassVariable.FormatErrorMsg, value);
    }

    public string FormatWarningMsg
    {
        get => GodotObject.Get(ClassVariable.FormatWarningMsg).AsString();
        set => GodotObject.Set(ClassVariable.FormatWarningMsg, value);
    }

    public string FormatNoticeMsg
    {
        get => GodotObject.Get(ClassVariable.FormatNoticeMsg).AsString();
        set => GodotObject.Set(ClassVariable.FormatNoticeMsg, value);
    }

    public string FormatInfoMsg
    {
        get => GodotObject.Get(ClassVariable.FormatInfoMsg).AsString();
        set => GodotObject.Set(ClassVariable.FormatInfoMsg, value);
    }

    public string FormatDebugMsg
    {
        get => GodotObject.Get(ClassVariable.FormatDebugMsg).AsString();
        set => GodotObject.Set(ClassVariable.FormatDebugMsg, value);
    }

    public string FormatTimestamp
    {
        get => GodotObject.Get(ClassVariable.FormatTimestamp).AsString();
        set => GodotObject.Set(ClassVariable.FormatTimestamp, value);
    }

    public string FormatStacktraceEntry
    {
        get => GodotObject.Get(ClassVariable.FormatStacktraceEntry).AsString();
        set => GodotObject.Set(ClassVariable.FormatStacktraceEntry, value);
    }

    public string HSeparatorSymbol
    {
        get => GodotObject.Get(ClassVariable.HSeparatorSymbol).AsString();
        set => GodotObject.Set(ClassVariable.HSeparatorSymbol, value);
    }

    public LoggieEnums.BoxCharactersMode BoxCharactersMode
    {
        get => GodotObject.Get(ClassVariable.BoxCharactersMode).As<LoggieEnums.BoxCharactersMode>();
        set => GodotObject.Set(ClassVariable.BoxCharactersMode, (int)value);
    }

    public Godot.Collections.Dictionary BoxSymbolsCompatible
    {
        get => GodotObject.Get(ClassVariable.BoxSymbolsCompatible).AsGodotDictionary();
        set => GodotObject.Set(ClassVariable.BoxSymbolsCompatible, value);
    }

    public Godot.Collections.Dictionary BoxSymbolsPretty
    {
        get => GodotObject.Get(ClassVariable.BoxSymbolsPretty).AsGodotDictionary();
        set => GodotObject.Set(ClassVariable.BoxSymbolsPretty, value);
    }

    public Callable CustomStringConverter
    {
        get => GodotObject.Get(ClassVariable.CustomStringConverter).AsCallable();
        set => GodotObject.Set(ClassVariable.CustomStringConverter, value);
    }

    public void Load()
    {
        GodotObject.Call(MethodName.Load);
    }

    public Godot.Collections.Dictionary ToDict()
    {
        return GodotObject.Call(MethodName.ToDict).AsGodotDictionary();
    }

    private static class ClassVariable
    {
        // Not Implemented
        // public static readonly StringName LoggieSingletonName = "loggie_singleton_name";
        public static readonly StringName ProjectSettings = "project_settings";
        public static readonly StringName UpdateCheckMode = "update_check_mode";
        public static readonly StringName MsgFormatMode = "msg_format_mode";
        public static readonly StringName LogLevel = "log_level";
        public static readonly StringName ShowLoggieSpecs = "show_loggie_specs";
        public static readonly StringName ShowSystemSpecs = "show_system_specs";
        public static readonly StringName PrintErrorsToConsole = "print_errors_to_console";
        public static readonly StringName PrintWarningsToConsole = "print_warnings_to_console";
        public static readonly StringName NamelessClassNameProxy = "nameless_class_name_proxy";
        public static readonly StringName TimestampsUseUtc = "timestamps_use_utc";
        public static readonly StringName DebugMsgsPrintStackTrace = "debug_msgs_print_stack_trace";

        public static readonly StringName EnforceOptimalSettingsInReleaseBuild =
            "enforce_optimal_settings_in_release_build";

        public static readonly StringName DiscordWebhookUrlDev = "discord_webhook_url_dev";
        public static readonly StringName DiscordWebhookUrlLive = "discord_webhook_url_live";
        public static readonly StringName SlackWebhookUrlDev = "slack_webhook_url_dev";
        public static readonly StringName SlackWebhookUrlLive = "slack_webhook_url_live";
        public static readonly StringName PreprocessFlagsTerminalChannel = "preprocess_flags_terminal_channel";
        public static readonly StringName PreprocessFlagsDiscordChannel = "preprocess_flags_discord_channel";
        public static readonly StringName PreprocessFlagsSlackChannel = "preprocess_flags_slack_channel";
        public static readonly StringName DefaultChannels = "default_channels";
        public static readonly StringName SkippedFilenamesInStackTrace = "skipped_filenames_in_stack_trace";
        public static readonly StringName FormatHeader = "format_header";
        public static readonly StringName FormatDomainPrefix = "format_domain_prefix";
        public static readonly StringName FormatErrorMsg = "format_error_msg";
        public static readonly StringName FormatWarningMsg = "format_warning_msg";
        public static readonly StringName FormatNoticeMsg = "format_notice_msg";
        public static readonly StringName FormatInfoMsg = "format_info_msg";
        public static readonly StringName FormatDebugMsg = "format_debug_msg";
        public static readonly StringName FormatTimestamp = "format_timestamp";
        public static readonly StringName FormatStacktraceEntry = "format_stacktrace_entry";
        public static readonly StringName HSeparatorSymbol = "h_separator_symbol";
        public static readonly StringName BoxCharactersMode = "box_characters_mode";
        public static readonly StringName BoxSymbolsCompatible = "box_symbols_compatible";
        public static readonly StringName BoxSymbolsPretty = "box_symbols_pretty";
        public static readonly StringName CustomStringConverter = "custom_string_converter";
    }

    private static class MethodName
    {
        public static readonly StringName Load = "load";
        public static readonly StringName ToDict = "to_dict";
    }
}

public class LoggieMsg(GodotObject godotObject)
{
    public readonly GodotObject GodotObject = godotObject;

    public Godot.Collections.Array Content
    {
        get => GodotObject.Get(ClassVariable.Content).AsGodotArray();
        set => GodotObject.Set(ClassVariable.Content, value);
    }

    public int CurrentSegmentIndex
    {
        get => GodotObject.Get(ClassVariable.CurrentSegmentIndex).AsInt32();
        set => GodotObject.Set(ClassVariable.CurrentSegmentIndex, value);
    }

    public string DomainName
    {
        get => GodotObject.Get(ClassVariable.DomainName).AsString();
        set => GodotObject.Set(ClassVariable.DomainName, value);
    }

    public Godot.Collections.Array UsedChannels
    {
        get => GodotObject.Get(ClassVariable.UsedChannels).AsGodotArray();
        set => GodotObject.Set(ClassVariable.UsedChannels, value);
    }

    public bool Preprocess
    {
        get => GodotObject.Get(ClassVariable.Preprocess).AsBool();
        set => GodotObject.Set(ClassVariable.Preprocess, value);
    }

    public int CustomPreprocessFlags
    {
        get => GodotObject.Get(ClassVariable.CustomPreprocessFlags).AsInt32();
        set => GodotObject.Set(ClassVariable.CustomPreprocessFlags, value);
    }

    public string LastPreprocessResult
    {
        get => GodotObject.Get(ClassVariable.LastPreprocessResult).AsString();
        set => GodotObject.Set(ClassVariable.LastPreprocessResult, value);
    }

    public bool AppendsStack
    {
        get => GodotObject.Get(ClassVariable.AppendsStack).AsBool();
        set => GodotObject.Set(ClassVariable.AppendsStack, value);
    }

    public Variant GetLogger()
    {
        return GodotObject.Call(MethodName.GetLogger);
    }

    public LoggieMsg UseLogger(Variant loggerToUse)
    {
        GodotObject.Call(MethodName.UseLogger, loggerToUse);
        return this;
    }

    public void Channel(Variant channels)
    {
        GodotObject.Call(MethodName.Channel, channels);
    }

    public string GetPreprocessed(int flags, LoggieEnums.LogLevel level)
    {
        return GodotObject.Call(MethodName.GetPreprocessed, flags, (int)level).AsString();
    }

    public void Output(LoggieEnums.LogLevel level, LoggieEnums.MsgType msgType = LoggieEnums.MsgType.Standard)
    {
        GodotObject.Call(MethodName.Output, (int)level, (int)msgType);
    }

    public LoggieMsg Error()
    {
        GodotObject.Call(MethodName.Error);
        return this;
    }

    public LoggieMsg Warn()
    {
        GodotObject.Call(MethodName.Warn);
        return this;
    }

    public LoggieMsg Notice()
    {
        GodotObject.Call(MethodName.Notice);
        return this;
    }

    public LoggieMsg Info()
    {
        GodotObject.Call(MethodName.Info);
        return this;
    }

    public LoggieMsg Debug()
    {
        GodotObject.Call(MethodName.Debug);
        return this;
    }

    public string String(int segment = -1)
    {
        return GodotObject.Call(MethodName.String, segment).AsString();
    }

    public LoggieMsg ToAnsi()
    {
        GodotObject.Call(MethodName.ToAnsi);
        return this;
    }

    public LoggieMsg StripBbCode()
    {
        GodotObject.Call(MethodName.StripBbCode);
        return this;
    }

    public LoggieMsg Color(Variant color)
    {
        GodotObject.Call(MethodName.Color, color);
        return this;
    }

    public LoggieMsg Bold()
    {
        GodotObject.Call(MethodName.Bold);
        return this;
    }

    public LoggieMsg Italic()
    {
        GodotObject.Call(MethodName.Italic);
        return this;
    }

    public LoggieMsg Header()
    {
        GodotObject.Call(MethodName.Header);
        return this;
    }

    public LoggieMsg Stack(bool enabled = true)
    {
        GodotObject.Call(MethodName.Stack, enabled);
        return this;
    }

    public LoggieMsg Box(int hPadding = 4)
    {
        GodotObject.Call(MethodName.Box, hPadding);
        return this;
    }

    public LoggieMsg Add(Variant? message = null, Variant? arg1 = null, Variant? arg2 = null, Variant? arg3 = null,
        Variant? arg4 = null, Variant? arg5 = null)
    {
        GodotObject.Call(MethodName.Add,
            message ?? new Variant(),
            arg1 ?? new Variant(),
            arg2 ?? new Variant(),
            arg3 ?? new Variant(),
            arg4 ?? new Variant(),
            arg5 ?? new Variant());
        return this;
    }

    public LoggieMsg Nl(int amount = 1)
    {
        GodotObject.Call(MethodName.Nl, amount);
        return this;
    }

    public LoggieMsg Space(int amount = 1)
    {
        GodotObject.Call(MethodName.Space, amount);
        return this;
    }

    public LoggieMsg Tab(int amount = 1)
    {
        GodotObject.Call(MethodName.Tab, amount);
        return this;
    }

    public LoggieMsg Domain(string domainName)
    {
        GodotObject.Call(MethodName.Domain, domainName);
        return this;
    }

    public LoggieMsg Prefix(string strPrefix, string separator = "")
    {
        GodotObject.Call(MethodName.Prefix, strPrefix, separator);
        return this;
    }

    public LoggieMsg Suffix(string strPrefix, string separator = "")
    {
        GodotObject.Call(MethodName.Suffix, strPrefix, separator);
        return this;
    }

    public LoggieMsg HSeparator(int size = 16, Variant? alternativeSymbol = null)
    {
        GodotObject.Call(MethodName.HSeparator, size, alternativeSymbol ?? new Variant());
        return this;
    }

    public LoggieMsg EndSeg()
    {
        GodotObject.Call(MethodName.EndSeg);
        return this;
    }

    public LoggieMsg Msg(Variant? message = null, Variant? arg1 = null, Variant? arg2 = null, Variant? arg3 = null,
        Variant? arg4 = null, Variant? arg5 = null)
    {
        GodotObject.Call(MethodName.Msg,
            message ?? new Variant(),
            arg1 ?? new Variant(),
            arg2 ?? new Variant(),
            arg3 ?? new Variant(),
            arg4 ?? new Variant(),
            arg5 ?? new Variant());
        return this;
    }

    public LoggieMsg Preprocessed(bool shouldPreprocess)
    {
        GodotObject.Call(MethodName.Preprocessed, shouldPreprocess);
        return this;
    }

    private static class ClassVariable
    {
        public static readonly StringName Content = "content";
        public static readonly StringName CurrentSegmentIndex = "current_segment_index";
        public static readonly StringName DomainName = "domain_name";
        public static readonly StringName UsedChannels = "used_channels";
        public static readonly StringName Preprocess = "preprocess";
        public static readonly StringName CustomPreprocessFlags = "custom_preprocess_flags";
        public static readonly StringName LastPreprocessResult = "last_preprocess_result";
        public static readonly StringName AppendsStack = "appends_stack";
    }

    private static class MethodName
    {
        public static readonly StringName GetLogger = "get_logger";
        public static readonly StringName UseLogger = "use_logger";
        public static readonly StringName Channel = "channel";
        public static readonly StringName GetPreprocessed = "get_preprocessed";
        public static readonly StringName Output = "output";
        public static readonly StringName Error = "error";
        public static readonly StringName Warn = "warn";
        public static readonly StringName Notice = "notice";
        public static readonly StringName Info = "info";
        public static readonly StringName Debug = "debug";
        public static readonly StringName String = "string";
        public static readonly StringName ToAnsi = "to_ANSI";
        public static readonly StringName StripBbCode = "strip_BBCode";
        public static readonly StringName Color = "color";
        public static readonly StringName Bold = "bold";
        public static readonly StringName Italic = "italic";
        public static readonly StringName Header = "header";
        public static readonly StringName Stack = "stack";
        public static readonly StringName Box = "box";
        public static readonly StringName Add = "add";
        public static readonly StringName Nl = "nl";
        public static readonly StringName Space = "space";
        public static readonly StringName Tab = "tab";
        public static readonly StringName Domain = "domain";
        public static readonly StringName Prefix = "prefix";
        public static readonly StringName Suffix = "suffix";
        public static readonly StringName HSeparator = "hseparator";
        public static readonly StringName EndSeg = "endseg";
        public static readonly StringName Msg = "msg";
        public static readonly StringName Preprocessed = "preprocessed";
    }
}

public class LoggieMsgChannel(GodotObject godotObject)
{
    public readonly GodotObject GodotObject = godotObject;

    public string Id
    {
        get => GodotObject.Get(ClassVariable.Id).AsString();
        set => GodotObject.Set(ClassVariable.Id, value);
    }

    public int PreprocessFlags
    {
        get => GodotObject.Get(ClassVariable.PreprocessFlags).AsInt32();
        set => GodotObject.Set(ClassVariable.PreprocessFlags, value);
    }

    public void Send(LoggieMsg msg, LoggieEnums.MsgType type)
    {
        GodotObject.Call(MethodName.Send, msg.GodotObject, (int)type);
    }

    private static class ClassVariable
    {
        public static readonly StringName Id = "ID";
        public static readonly StringName PreprocessFlags = "preprocess_flags";
    }

    private static class MethodName
    {
        public static readonly StringName Send = "send";
    }
}

/**
 * TODO: extract these enum values from the relevant gdscript
 * class to prevent breakage if the underlying enums change
 */
public static class LoggieEnums
{
    public enum LogLevel
    {
        Error = 1,
        Warn = 2,
        Notice = 3,
        Info = 4,
        Debug = 5,
    }

    public enum MsgType
    {
        Standard = 1,
        Error = 2,
        Warning = 3,
        Debug = 4,
    }

    public enum MsgFormatMode
    {
        Plain = 1,
        Ansi = 2,
        BbCode = 3,
        Markdown = 4,
    }

    public enum PreprocessStep
    {
        AppendTimestamps = 1 << 0,
        AppendDomainName = 1 << 1,
        AppendClassName = 1 << 2,
    }

    public enum BoxCharactersMode
    {
        Compatible = 1,
        Pretty = 2,
    }

    public enum NamelessClassExtensionNameProxy
    {
        Nothing = 1,
        ScriptName = 2,
        BaseType = 3,
    }

    public enum ShowLoggieSpecsMode
    {
        Disabled = 1,
        Essential = 2,
        Advanced = 3,
    }

    public enum LogAttemptResult
    {
        Success = 1,
        LogLevelInsufficient = 2,
        DomainDisabled = 3,
        InvalidChannel = 4,
    }

    public enum UpdateCheckType
    {
        DontCheck = 1,
        CheckAndShowMsg = 2,
        CheckDownloadAndShowMsg = 3,
        CheckAndShowUpdaterWindow = 4,
    }
}