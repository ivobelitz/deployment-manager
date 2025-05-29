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
                          PublishList? publishes
                          SubscribeList? subscribes
                          PortsList? ports
                          VolumesList? volumes
                          CopyFiles? copyFiles
                          Config? config
                          BuildCommands? buildCommands
                          ExecutionCommand? executionCommand
                          "}";

// Defining a runtime (Python, Java, etc.) along with its version and packages
syntax Runtime = runtime: "runtime" String name "{" 
                          VersionDecl? version 
                          PackagesDecl? packages 
                          "}";

syntax VersionDecl = versionDecl: "version" "=" String version;

syntax PackagesDecl = packagesDecl: "packages" "=" "[" {String ","}* packageList "]";

// Execution command that starts the application
syntax ExecutionCommand = executionCommand: "executionCommand" "=" String command;

// Build commands that are executed during the build process
syntax BuildCommands = buildCommands: "buildCommands" "=" "[" {String ","}* commands "]";

// List of data points that the container publishes / sends data
syntax PublishList = publishList: "publishes" "=" "[" {PublishTopic ","}* topics "]";
syntax PublishTopic = publishTopic: String topic;

// List of data points that the container subscribes / listens to
syntax SubscribeList = subscribeList: "subscribes" "=" "[" {SubscribeTopic ","}* topics "]";
syntax SubscribeTopic = subscribeTopic: String topic;

// List of ports to expose from the container
syntax PortsList = portsList: "ports" "=" "[" {Int ","}* ports "]";

// List of volumes to mount into the container
syntax VolumesList = volumesList: "volumes" "=" "[" {VolumeItem ","}* items "]";

syntax VolumeItem = volumeItem: "{" "from" "=" String source "," "to" "=" String destination "}";

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