module Syntax

extend lang::std::Layout;
extend lang::std::Id;

start syntax Deployment = deployment: HardwareNode+ hardwareNodes;

syntax HardwareNode = hardwareNode: "HardwareNode" Id name;