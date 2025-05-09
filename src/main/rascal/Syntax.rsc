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
                          PublishesDecl? publishes
                          SubscribesDecl? subscribes
                          "}";

syntax Runtime = runtime: "runtime" String name "{" 
                          VersionDecl? version 
                          PackagesDecl? packages 
                          "}";

syntax VersionDecl = versionDecl: "version" "=" String version;

syntax PackagesDecl = packagesDecl: "packages" "=" "[" {String ","}* packageList "]";

syntax Command = command: "command" "=" String command;

syntax PublishesDecl = publishesDecl: "publishes" "=" "[" {String ","}* topics "]";

syntax SubscribesDecl = subscribesDecl: "subscribes" "=" "[" {String ","}* topics "]";

lexical String = "\"" ![\"]*  "\"";