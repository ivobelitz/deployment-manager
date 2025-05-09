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

  for (Hardware h <- d.hardwares) {
    for (Service s <- h.services) {
      str serviceName = stripQuotes("<s.name>");
      dockerComposeContent += insertTabs(1) + serviceName + ": \n";
      dockerComposeContent += insertTabs(2) + "build: ./<serviceName>\n";
      dockerComposeContent += insertTabs(2) + "container_name: <serviceName>\n";

      if (PublishesDecl publishesDecl <- s.publishes || SubscribesDecl subscribesDecl <- s.subscribes) {
        dockerComposeContent += insertTabs(2) + "environment: \n";  
        dockerComposeContent += insertTabs(3) + "- RABBITMQ_HOST=rabbitmq\n";
      }

      if (PublishesDecl publishesDecl <- s.publishes) {
        str packagesStr = "<publishesDecl.topics>";
        list[str] topics = parsePackageList(packagesStr);
        println(topics);
        
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
      
      if (SubscribesDecl subscribesDecl <- s.subscribes) {
        str packagesStr = "<subscribesDecl.topics>";
        list[str] topics = parsePackageList(packagesStr);
        
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
    }
  } 
  str outputDir = "output/";
  return file(dockerComposeContent, outputDir);
}
