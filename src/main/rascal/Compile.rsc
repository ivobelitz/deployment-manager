module Compile

import Syntax;
import ParseTree;
import lang::smtlib2::Compiler;

data SoftwareNodeOutput = softwareNodeOutput(str content, str outputDir);

list[SoftwareNodeOutput] compile(Deployment d) {
  // Extract all dependencies from all software nodes across all hardware nodes
  list[SoftwareNodeOutput] results = [];
  
  for (HardwareNode hn <- d.hardwareNodes) {
    for (SoftwareNode sn <- hn.softwareNodes) {
      results += parseSoftwareNode(sn);
    }
  }
  return results;
}

SoftwareNodeOutput parseSoftwareNode(SoftwareNode sn) {
  str result = "";
  result += "FROM ubuntu:latest\n";
  result += "RUN apt-get update && apt-get install -y \\\n";
  for (Dependency d <- sn.dependencies.depList) {
    result += "  " + resolveDependency("<d>") + " \\\n";
  }
  
  result += "COPY . /app\n";
  result += "RUN make /app\n";
  
  // Determine output directory - use default if not specified
  str outputDir = getOutputDir(sn);
  
  return softwareNodeOutput(result, outputDir);
}

str resolveDependency(str name) {
  switch (name) {
    case "Python": return "python:3.8";
    case "Java": return "openjdk-11-jre-headless";
    case "Node": return "node:14";
    case "Ruby": return "ruby:2.7";
    case "Go": return "golang:1.16";
    default: return "alpine:latest"; // Default base image if dependency not recognized
  }
}

str getOutputDir(SoftwareNode sn) {
  return "output/<sn.name>"; // Always use the software node name for the output directory
}