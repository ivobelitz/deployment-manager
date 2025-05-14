module Dockerfiles

import Syntax;
import Runtimes;
import String;
import Helper;
import Main;
import Datamodel;
import IO;

list[File] getDockerFiles(Deployment d) {
  list[File] results = [];
  
  for (Hardware h <- d.hardwares) {
    for (Service s <- h.services) {
      results += prepareDockerfile(s);
    }
  }
  return results;
}

File prepareDockerfile(Service s) {
  str result = "";
  result += "FROM ubuntu:latest\n"; // Use a lightweight base image
  for (Runtime r <- s.runtimes) {
    result += "<resolveRuntime(r)>\n";
  }
  
  if (CopyFiles copyFiles <- s.copyFiles) {
    for (CopyFileItem item <- copyFiles.items) {
      str source = stripQuotes("<item.source>");
      str destination = stripQuotes("<item.destination>");
      result += "COPY <source> <destination>\n";
    }
    result += "\n";
  }

  result += resolveExecutionCommand("<s.command.command>");
  
  // Determine output directory - use default if not specified
  str outputDir = getOutputDir(s);
  
  return file(result, outputDir, "Dockerfile");
}

str resolveExecutionCommand(str input) {
    str command = "CMD <stripQuotes("<input>")>";
    return command;
}

str getOutputDir(Service s) {
  str serviceName = stripQuotes("<s.name>");
  return "output/<serviceName>/";
}