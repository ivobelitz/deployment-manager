module Syntax

extend lang::std::Layout;
extend lang::std::Id;
extend lang::std::Whitespace;
extend lang::std::Comment;

start syntax Deployment = deployment: HardwareNode+ hardwareNodes;

syntax HardwareNode = hardwareNode: "HardwareNode" Id name SoftwareNode* softwareNodes;

syntax SoftwareNode = softwareNode: "SoftwareNode" Id name Dependencies dependencies;

syntax Dependencies = dependencies: "Dependencies" "[" {Dependency ","}+ depList "]";

syntax Dependency = dependency: Id name;

syntax Str = string: "\"" ![\"]*  "\"";