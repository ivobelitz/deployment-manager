module Dockerfiles

import Syntax;
import Runtimes;
import String;
import Helper;
import Main;
import Datamodel;
import IO;
import Type; 

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

  if (VolumesList volumesList <- s.volumes) {
    for (VolumeItem item <- volumesList.items) {
        str destination = stripQuotes("<item.destination>");
        result += "RUN mkdir -p <destination>\n";
      }
      result += "\n";
  }

  if (BuildCommands buildCommands <- s.buildCommands) {
    list[str] commands = parseList("<buildCommands.commands>");
    for (str command <- commands) {
      result += "RUN <stripQuotes(command)>\n";
    }
    result += "\n";
  }

  if (ExecutionCommand executionCommand <- s.executionCommand) {
    str command = stripQuotes("<executionCommand.command>");
    result += "CMD <command>\n";
  }
  
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