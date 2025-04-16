module Main

import ParseTree;
import Syntax;
import IO;
import Compile;

void main() {
    // Parse the input file and generate the Dockerfile
    Deployment d = parseDeployment("example.dep");

    list[SoftwareNodeOutput] dockerFiles = compile(d);

    for (SoftwareNodeOutput output <- dockerFiles) {
        generateDockerfile(output);
    }
}

void generateDockerfile(SoftwareNodeOutput output) {
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

Deployment parseDeployment(str inputPath) {
    start[Deployment] parsedDeployment = parse(#start[Deployment], |project://deployment-manager/<inputPath>|);
    return parsedDeployment.top;
}