module Syntax

extend lang::std::Layout;
extend lang::std::Id;
extend lang::std::Whitespace;
extend lang::std::Comment;

start syntax Deployment = deployment: Hardware+ hardwares;

syntax Hardware = hardware: "hardware" String name "{" Service* services "}";

syntax Service = service: "service" String name "{" 
                          Runtime+ runtimes
                          Command command
                          PublishList? publishes
                          SubscribeList? subscribes
                          Config? config
                          "}";

syntax Runtime = runtime: "runtime" String name "{" 
                          VersionDecl? version 
                          PackagesDecl? packages 
                          "}";

syntax VersionDecl = versionDecl: "version" "=" String version;

syntax PackagesDecl = packagesDecl: "packages" "=" "[" {String ","}* packageList "]";

syntax Command = command: "command" "=" String command;

syntax PublishList = publishList: "publishes" "=" "[" {String ","}* topics "]";

syntax SubscribeList = subscribeList: "subscribes" "=" "[" {String ","}* topics "]";

syntax Config = config: "config" "=" "{" {ConfigItem ","}* items "}";

syntax ConfigItem = configItem: String k ":" ConfigValue v;

syntax ConfigValue = 
                   | stringVal: String string
                   | intVal: Int integer
                   | floatVal: Float float
                   | boolVal: Boolean boolean;

lexical Int = [0-9]+;
lexical Float = [0-9]+ "." [0-9]+;
lexical Boolean = "true" | "false";
lexical String = "\"" ![\"]*  "\"";