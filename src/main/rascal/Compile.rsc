module Compile

import Syntax;
import Runtimes;
import ParseTree;
import lang::smtlib2::Compiler;
import String;
import Helper;

data SoftwareNodeOutput = softwareNodeOutput(str content, str outputDir);

list[SoftwareNodeOutput] getDockerFiles(Deployment d) {
  // Extract all dependencies from all software nodes across all hardware nodes
  list[SoftwareNodeOutput] results = [];
  
  for (Hardware h <- d.hardwares) {
    for (Service s <- h.services) {
      results += prepareDockerfile(s);
    }
  }
  return results;
}

SoftwareNodeOutput prepareDockerfile(Service s) {
  str result = "";
  result += "FROM ubuntu:latest\n";
  for (Runtime r <- s.runtimes) {
    result += resolveRuntime(r) + " \n";
  }
  
  result += "COPY . /app\n";
  // result += resolveExecutionCommand("<s.command>");
  
  // Determine output directory - use default if not specified
  str outputDir = getOutputDir(s);
  
  return softwareNodeOutput(result, outputDir);
}

str resolveExecutionCommand(str input) {
    str command = "CMD [";
    list[str] args = split(" ", input);
    for (int i <- [0 .. size(args) - 1]) {
        command += "<args[i]>\", ";
    }
    int i = size(args);
    command += "\"<args[i - 1]>";
    command += "]";
    return command;
}

str getOutputDir(Service s) {
  str serviceName = stripQuotes("<s.name>");
  return "output/" + serviceName + "/";
}

SoftwareNodeOutput getDockerComposeFile(Deployment d) {
  str dockerComposeContent = "version: \'3\' \nservices: \n";
  
  for (Hardware h <- d.hardwares) {
    for (Service s <- h.services) {
      str serviceName = stripQuotes("<s.name>");
      dockerComposeContent += "  " + serviceName + ": \n";
      dockerComposeContent += "    build: ./<serviceName>\n";
      dockerComposeContent += "    container_name: <serviceName>\n";

      if (PublishesDecl publishesDecl <- s.publishes || SubscribesDecl subscribesDecl <- s.subscribes) {
        dockerComposeContent += "    environment: \n";  
        dockerComposeContent += "      - RABBITMQ_HOST=rabbitmq\n";
      }

      if (PublishesDecl publishesDecl <- s.publishes) {
        list[str] topics = parsePackageList("<publishesDecl.topics>");
        for (str topic <- topics) {
          dockerComposeContent += "      - PUB_QUEUE=<topic>\n";
        }
      }
      if (SubscribesDecl subscribesDecl <- s.subscribes) {
        list[str] topics = parsePackageList("<subscribesDecl.topics>");
        for (str topic <- topics) {
          dockerComposeContent += "      - SUB_QUEUE=<topic>\n";
        }
      }
    }
  } 
  str outputDir = "output/";
  return softwareNodeOutput(dockerComposeContent, outputDir);
} 
