module Syntax

extend lang::std::Layout;
extend lang::std::Id;
extend lang::std::Whitespace;
extend lang::std::Comment;

// Deployment contains a set of hardwares
start syntax Deployment = deployment: Hardware+ hardwares DataConfig? dataConfig;

// Hardware contains a set of services
syntax Hardware = hardware: "hardware" String name "{" Service* services "}";

// Service contains a number of concepts 
syntax Service = service: "service" String name "{" 
                          Runtime+ runtimes
                          SendsList? sends
                          ReceivesList? receives
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

syntax PackagesDecl = packagesDecl: "packages" "=" "[" {PackageItem ","}* packageList "]";

syntax PackageItem = packageItem: "{" "name" "=" String name ("," "version" "=" String version)? "}";

// Execution command that starts the application
syntax ExecutionCommand = executionCommand: "executionCommand" "=" String command;

// Build commands that are executed during the build process
syntax BuildCommands = buildCommands: "buildCommands" "=" "[" {String ","}* commands "]";

// List of data points that the container sends data
syntax SendsList = sendsList: "sends" "=" "[" {SendsTopic ","}* topics "]";
syntax SendsTopic = sendsTopic: String topic;

// List of data points that the container receives / listens to
syntax ReceivesList = receivesList: "receives" "=" "[" {ReceivesTopic ","}* topics "]";
syntax ReceivesTopic = receivesTopic: String topic;

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

syntax DataConfig = dataConfig: "data" "{" {DataItem ","}* items "}";

syntax EndpointDecl = endpointDecl: "endpoint" "=" String endpoint;

syntax DataItem = dataItem: String name "{" 
                            "protocol" "=" String protocol ","
                            "address" "=" String address ","
                            "port" "=" Int port ","?
                            EndpointDecl? endpoint "}";

syntax ConfigValue = 
                   | stringVal: String string
                   | intVal: Int integer
                   | floatVal: Float float
                   | boolVal: Boolean boolean;

lexical Int = [0-9]+;
lexical Float = [0-9]+ "." [0-9]+;
lexical Boolean = "true" | "false";
lexical String = "\"" ![\"]*  "\"";