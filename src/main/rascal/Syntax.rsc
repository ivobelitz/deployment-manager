module Syntax

extend lang::std::Layout;
extend lang::std::Id;
extend lang::std::Whitespace;
extend lang::std::Comment;

start syntax Deployment = deployment: HardwareNode+ hardwareNodes;

syntax HardwareNode = hardwareNode: "HardwareNode" Id name SoftwareNode* softwareNodes;

syntax SoftwareNode = softwareNode: "SoftwareNode" Id name Dependencies dependencies ExecutionCommand executionCommand;

syntax Dependencies = dependencies: "Dependencies" "[" {Dependency ","}+ depList "]";

syntax Dependency = dependency: Id name;

syntax ExecutionCommand = command: "ExecutionCommand" Str command;

syntax Str = string: "\"" ![\"]*  "\"";