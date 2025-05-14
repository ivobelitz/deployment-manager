module Syntax

extend lang::std::Layout;
extend lang::std::Id;
extend lang::std::Whitespace;
extend lang::std::Comment;

// Deployment contains a set of hardwares
start syntax Deployment = deployment: Hardware+ hardwares;

// Hardware contains a set of services
syntax Hardware = hardware: "hardware" String name "{" Service* services "}";

// Service contains a number of concepts 
syntax Service = service: "service" String name "{" 
                          Runtime+ runtimes
                          Command command
                          PublishList? publishes
                          SubscribeList? subscribes
                          CopyFiles? copyFiles
                          Config? config
                          "}";

// Defining a runtime (Python, Java, etc.) along with its version and packages
syntax Runtime = runtime: "runtime" String name "{" 
                          VersionDecl? version 
                          PackagesDecl? packages 
                          "}";

syntax VersionDecl = versionDecl: "version" "=" String version;

syntax PackagesDecl = packagesDecl: "packages" "=" "[" {String ","}* packageList "]";

// Execution command that starts the application
syntax Command = command: "command" "=" String command;

// List of data points that the container publishes / sends data
syntax PublishList = publishList: "publishes" "=" "[" {String ","}* topics "]";

// List of data points that the container subscribes / listens to
syntax SubscribeList = subscribeList: "subscribes" "=" "[" {String ","}* topics "]";

// List of files that are copied into the container
syntax CopyFiles = copyFiles: "copy" "=" "[" {CopyFileItem ","}* items "]";

syntax CopyFileItem = copyFileItem: "{" "from" "=" String source "," "to" "=" String destination "}";

// Configuration specific to the application
// Gets transformed into a "config.json" file that can be used within the application
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