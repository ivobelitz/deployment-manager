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
  str dockerComposeContent = "services: \n";

  bool hasNetworkServices = false;

  for (Hardware h <- d.hardwares) {
    for (Service s <- h.services) {
      str serviceName = stripQuotes("<s.name>");
      dockerComposeContent += insertTabs(1) + serviceName + ": \n";
      dockerComposeContent += insertTabs(2) + "image: <serviceName>\n";

      // Check if service needs network access (has ports, publishes, or subscribes)
      bool needsNetwork = false;
      
      // Add ports mapping if specified
      if (PortsList portsList <- s.ports) {
        needsNetwork = true;
        dockerComposeContent += insertTabs(2) + "ports: \n";
        for (port <- portsList.ports) {
          dockerComposeContent += insertTabs(3) + "- <port>:<port>\n";
        }
      }
      
      // Check if service publishes or subscribes (needs network for communication)
      if (PublishList publishesList <- s.publishes) {
        needsNetwork = true;
      }
      
      if (SubscribeList subscribesList <- s.subscribes) {
        needsNetwork = true;
      }
      
      // Add volumes mapping if specified
      if (VolumesList volumesList <- s.volumes) {
        dockerComposeContent += insertTabs(2) + "volumes: \n";
        for (VolumeItem item <- volumesList.items) {
          str source = stripQuotes("<item.source>");
          str destination = stripQuotes("<item.destination>");
          dockerComposeContent += insertTabs(3) + "- <source>:<destination>\n";
        }
      }

      // Add service to network if it needs network access
      if (needsNetwork) {
        hasNetworkServices = true;
        dockerComposeContent += insertTabs(2) + "networks: \n";
        dockerComposeContent += insertTabs(3) + "- app-network\n"; 
      }
      
      // Add volume mount for config.json if service has configuration
      // if (Config config <- s.config) {
      //   str hardwareName = stripQuotes("<h.name>");
      //   if (!contains(dockerComposeContent, insertTabs(2) + "volumes:")) {
      //     dockerComposeContent += insertTabs(2) + "volumes:\n";
      //   }
      //   dockerComposeContent += insertTabs(3) + "- ./<hardwareName>/<serviceName>/config.json:/app/config.json\n";
      // }
    }
  }
  
  // Add network configuration if any service needs network access
  if (hasNetworkServices) {
    dockerComposeContent += "networks:\n";
    dockerComposeContent += insertTabs(1) + "app-network:\n";
    dockerComposeContent += insertTabs(2) + "driver: bridge\n";
  }
  
  str outputDir = "output/";
  return file(dockerComposeContent, outputDir, "docker-compose.yml");
}
