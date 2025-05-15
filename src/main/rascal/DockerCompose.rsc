module DockerCompose

import Syntax;
import Runtimes;
import String;
import Helper;
import Main;
import Datamodel;
import IO;
import List;

File getDockerComposeFile(Deployment d) {
  str dockerComposeContent = "version: \'3\' \nservices: \n";

  bool hasPorts = false;

  for (Hardware h <- d.hardwares) {
    for (Service s <- h.services) {
      str serviceName = stripQuotes("<s.name>");
      dockerComposeContent += insertTabs(1) + serviceName + ": \n";
      dockerComposeContent += insertTabs(2) + "image: <serviceName>\n";

      // Add ports mapping if specified
      if (PortsList portsList <- s.ports) {
        hasPorts = true;
        dockerComposeContent += insertTabs(2) + "ports: \n";
        for (port <- portsList.ports) {
          dockerComposeContent += insertTabs(3) + "- <port>:<port>\n";
        }
        dockerComposeContent += insertTabs(2) + "networks: \n";
        dockerComposeContent += insertTabs(3) + " - app-network\n";
      }

      if (PublishList publishList <- s.publishes || SubscribeList subscribeList <- s.subscribes) {
        dockerComposeContent += insertTabs(2) + "environment: \n";  
        dockerComposeContent += insertTabs(3) + "- RABBITMQ_HOST=rabbitmq\n";
      }

      if (PublishList publishList <- s.publishes) {
        str packagesStr = "<publishList.topics>";
        list[str] topics = parseList(packagesStr);
        // println(topics);
        
        // Transform topics list to JSON format: {"topic1": "topic1", "topic2": "topic2", ...}
        if (size(topics) > 0) {
          str jsonTopics = "{";     
          for (int i <- [0..size(topics)]) {
            jsonTopics += "\\\"<topics[i]>\\\": \\\"<topics[i]>\\\"";
            if (i < size(topics) - 1) {
              jsonTopics += ", ";
            }
          }
          jsonTopics += "}";
          
          dockerComposeContent += insertTabs(3) + "- \"PUB_TOPICS=<jsonTopics>\"\n";         
        }
      }
      
      if (SubscribeList subscribeList <- s.subscribes) {
        str packagesStr = "<subscribeList.topics>";
        list[str] topics = parseList(packagesStr);
        
        // Transform topics list to JSON format: {"topic1": "topic1", "topic2": "topic2", ...}
        if (size(topics) > 0) {
          str jsonTopics = "{";
          for (int i <- [0..size(topics)]) {
            jsonTopics += "\\\"<topics[i]>\\\": \\\"<topics[i]>\\\"";
            if (i < size(topics) - 1) {
              jsonTopics += ", ";
            }
          }
          jsonTopics += "}";
          
          dockerComposeContent += insertTabs(3) + "- \"SUB_TOPICS=<jsonTopics>\"\n";
        }
      }
      
      // Add volume mount for config.json if service has configuration
      // if (Config config <- s.config) {
      //   if (!contains(dockerComposeContent, insertTabs(2) + "volumes:")) {
      //     dockerComposeContent += insertTabs(2) + "volumes:\n";
      //   }
      //   dockerComposeContent += insertTabs(3) + "- ./<serviceName>/config.json:/app/config.json\n";
      // }
    }
    // Add network configuration for the hardware
    if (hasPorts) {
      dockerComposeContent += "networks:\n";
      dockerComposeContent += insertTabs(1) + "app-network:\n";
      dockerComposeContent += insertTabs(2) + "driver: bridge\n";
    }
  } 
  str outputDir = "output/";
  return file(dockerComposeContent, outputDir, "docker-compose.yml");
}
