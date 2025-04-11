module Compile

import Syntax;
import lang::smtlib2::Compiler;

list[str] compile(Deployment d) {
  // Extract all dependencies from all software nodes across all hardware nodes
  str result = "";
  for (HardwareNode hn <- d.hardwareNodes) {
    for (SoftwareNode sn <- hn.softwareNodes) {
      result += "FROM <resolveDependency(sn.dependencies)>\n";
    }
  }
  return [result];
}
str resolveDependency(Dependency d) {
    str name = "<d.name>";
  switch (name) {
    case "Python": return "python:3.8";
    case "Java": return "openjdk:11";
    case "Node": return "node:14";
    case "Ruby": return "ruby:2.7";
    case "Go": return "golang:1.16";
    default: return "alpine:latest"; // Default base image if dependency not recognized
  }
}