module Main

import ParseTree;
import Syntax;
import IO;
import Dockerfiles;
import DockerCompose;
import Datamodel;

void main() {
    // Parse the input file and generate the Dockerfile
    Deployment d = parseDeployment("example.dep");

    list[File] dockerFiles = getDockerFiles(d);
    File dockerComposeFile = getDockerComposeFile(d);

    for (File output <- dockerFiles) {
        writeDockerfile(output);
    }
    writeDockerComposeFile(dockerComposeFile);
}

void writeDockerfile(File output) {
    // Ensure directory exists
    loc outputDir = |project://deployment-manager/<output.outputDir>|;
    if (!exists(outputDir)) {
        mkDirectory(outputDir);
    }
    
    // Create the Dockerfile in the specified directory
    loc outputFile = outputDir + "Dockerfile";
    writeFile(outputFile, output.content);
    println("Dockerfile generated successfully at: <outputFile>");
}

void writeDockerComposeFile(File output) {
    // Ensure directory exists
    loc outputDir = |project://deployment-manager/<output.outputDir>|;
    if (!exists(outputDir)) {
        mkDirectory(outputDir);
    }
    
    // Create the Docker Compose file in the specified directory
    loc outputFile = outputDir + "docker-compose.yml";
    writeFile(outputFile, output.content);
    println("Docker Compose file generated successfully at: <outputFile>");
}

Deployment parseDeployment(str inputPath) {
    start[Deployment] parsedDeployment = parse(#start[Deployment], |project://deployment-manager/<inputPath>|);
    return parsedDeployment.top;
}