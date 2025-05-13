module Main

import ParseTree;
import Syntax;
import IO;
import Dockerfiles;
import DockerCompose;
import ConfigurationFiles;
import Datamodel;

void main() {
    // Parse the input file and generate files
    Deployment d = parseDeployment("example.dep");

    list[File] dockerFiles = getDockerFiles(d);
    File dockerComposeFile = getDockerComposeFile(d);
    list[File] configFiles = getConfigFiles(d);

    for (File output <- dockerFiles) {
        writeFile(output);
    }

    for (File output <- configFiles) {
        writeFile(output);
    }

    writeFile(dockerComposeFile);
}

void writeFile(File output) {
    // Ensure directory exists
    loc outputDir = |project://deployment-manager/<output.outputDir>|;
    if (!exists(outputDir)) {
        mkDirectory(outputDir);
    }
    
    // Create the file in the specified directory
    loc outputFile = outputDir + output.fileName;
    writeFile(outputFile, output.content);
    println("File <outputFile> generated successfully at: <outputFile>");
}

Deployment parseDeployment(str inputPath) {
    start[Deployment] parsedDeployment = parse(#start[Deployment], |project://deployment-manager/<inputPath>|);
    return parsedDeployment.top;
}