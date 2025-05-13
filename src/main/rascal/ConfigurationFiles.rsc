// filepath: /home/ivo/master/dsls/deployment-manager/src/main/rascal/ConfigurationFiles.rsc
module ConfigurationFiles

import Syntax;
import Helper;
import String;
import IO;
import Datamodel;
import Node;
import List;
import Type;

list[File] getConfigFiles(Deployment d) {
  list[File] results = [];
  
  for (Hardware h <- d.hardwares) {
    for (Service s <- h.services)   {
      if (Config config <- s.config) {
        results += prepareConfigFile(s, config);
      }
    }
  }
  return results;
}

File prepareConfigFile(Service s, Config config) {
  str serviceName = stripQuotes("<s.name>");
  str jsonContent = "{\n";
  
  // Process each configuration item
  list[ConfigItem] items = [item | item <- config.items];
  int totalItems = size(items);
  
  for (int i <- [0..totalItems]) {
    ConfigItem item = items[i];
    str k = stripQuotes("<item.k>");
    str v = convertConfigValueToJson(item.v);
    
    jsonContent += insertTabs(1) + "\"<k>\": <v>";
    
    // Add comma if not the last item
    if (i < totalItems - 1) {
      jsonContent += ",";
    }
    jsonContent += "\n";
  }
  
  jsonContent += "}";
  
  // Define the output directory
  str outputDir = "output/" + serviceName + "/";
  
  return file(jsonContent, outputDir, "config.json");
}

str convertConfigValueToJson(ConfigValue cv) {
  switch (cv) {
    case stringVal(String s): return "\"" + stripQuotes("<s>") + "\"";
    case intVal(Int i): return "<i>";
    case floatVal(Float f): return "<f>";
    case boolVal(Boolean b): return "<b>";
    default: return "null";
  }
}

//! This is unnecassary
void writeConfigFile(File output) {
  // Ensure directory exists
  loc outputDir = |project://deployment-manager/<output.outputDir>|;
  if (!exists(outputDir)) {
    mkDirectory(outputDir);
  }
  
  // Create the config.json file in the specified directory
  loc outputFile = outputDir + output.fileName;
  writeFile(outputFile, output.content);
  println("Configuration file generated successfully at: <outputFile>");
}