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
      // Check if service has any configuration to generate
      if (hasConfiguration(s, d)) {
        results += prepareConfigFile(s, d, h);
      }
    }
  }
  return results;
}

bool hasConfiguration(Service s, Deployment d) {
  // Check if service has explicit config parameters
  if (Config config <- s.config) {
    if (size([item | item <- config.items]) > 0) {
      return true;
    }
  }
  
  // Check if service has publish topics
  if (PublishList publishList <- s.publishes) {
    list[str] publishTopics = parseList("<publishList.topics>");
    if (size(publishTopics) > 0) {
      return true;
    }
  }
  
  // Check if service has subscribe topics
  if (SubscribeList subscribeList <- s.subscribes) {
    list[str] subscribeTopics = parseList("<subscribeList.topics>");
    if (size(subscribeTopics) > 0) {
      return true;
    }
  }
  
  return false;
}

File prepareConfigFile(Service s, Deployment d, Hardware h) {
  str serviceName = stripQuotes("<s.name>");
  str jsonContent = "{\n";
  
  list[str] configLines = [];

  if (Config config <- s.config) {
    // Process each configuration item
    list[ConfigItem] items = [item | item <- config.items];
    
    for (ConfigItem item <- items) {
      str k = stripQuotes("<item.k>");
      str v = convertConfigValueToJson(item.v);
      configLines += "\"<k>\": <v>";
    }
  }
  
  // Add publish topics to configuration
  if (PublishList publishList <- s.publishes) {
    list[str] publishTopics = parseList("<publishList.topics>");
    for (str topic <- publishTopics) {
      str topicName = stripQuotes(topic);
      configLines += "\"<topicName>_topic\": \"<topicName>\"";
    }
  }
  
  // Add subscribe topics to configuration
  if (SubscribeList subscribeList <- s.subscribes) {
    list[str] subscribeTopics = parseList("<subscribeList.topics>");
    for (str topic <- subscribeTopics) {
      str topicName = stripQuotes(topic);
      configLines += "\"<topicName>_topic\": \"<topicName>\"";
    }
  }
  
  // Join all configuration lines with commas
  for (int i <- [0..size(configLines)]) {
    jsonContent += insertTabs(1) + configLines[i];
    if (i < size(configLines) - 1) {
      jsonContent += ",\n";
    } else {
      jsonContent += "\n";
    }
  }

  if (DataConfig dataConfig <- d.dataConfig) {
      list[DataItem] dataItems = [dataItem | dataItem <- dataConfig.items];

      // Get all topics this service publishes to and subscribes from
      list[str] topics = [];
      if (PublishList publishList <- s.publishes) {
        topics += parseList("<publishList.topics>");
      }
      if (SubscribeList subscribeList <- s.subscribes) {
        topics += parseList("<subscribeList.topics>");
      }
      topics = dup(topics);

      // Filter data items to only include topics used by this service
      list[DataItem] relevantDataItems = [dataItem | DataItem dataItem <- dataItems, stripQuotes("<dataItem.name>") in topics];
      
      if (size(relevantDataItems) > 0) {
        if (size(configLines) > 0) {
          jsonContent += ",\n";
        }
        
        int totalRelevantItems = size(relevantDataItems);
        for (int i <- [0..totalRelevantItems]) {
          DataItem dataItem = relevantDataItems[i];
          str dataItemName = stripQuotes("<dataItem.name>");
          
          jsonContent += insertTabs(1) + "\"<dataItemName>\": {\n";
          jsonContent += insertTabs(2) + "\"protocol\": <dataItem.protocol>,\n";
          jsonContent += insertTabs(2) + "\"address\": <dataItem.address>,\n";
          jsonContent += insertTabs(2) + "\"port\": <dataItem.port>";
          
          // Add endpoint if it exists
          if (EndpointDecl endpointDecl <- dataItem.endpoint) {
            jsonContent += ",\n";
            jsonContent += insertTabs(2) + "\"endpoint\": <endpointDecl.endpoint>";
          }
          
          jsonContent += "\n";
          jsonContent += insertTabs(1) + "}";
          
          // Add comma if not the last relevant item
          if (i < totalRelevantItems - 1) {
            jsonContent += ",";
          }
          jsonContent += "\n";
        }
      }
  }

  jsonContent += "\n}";
  
  // Define the output directory with hardware/service structure
  str hardwareName = stripQuotes("<h.name>");
  str outputDir = "output/" + hardwareName + "/" + serviceName + "/";
  
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

