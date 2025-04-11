module Main

import ParseTree;
import Syntax;
import IO;
import Compile;

void main(int testArgument=0) {
    // Parse the input file and generate the Dockerfile
    Deployment d = parseDeployment("example.dep");

    list[str] dockerFiles = compile(d);

    int i = 1;

    for (str dockerFile <- dockerFiles) {
        loc outputFile = |project://deployment-manager/output/Dockerfile.<"<i>">|;
        generateDockerfile(outputFile, dockerFile);
        i+= 1;
    }
}

void generateDockerfile(loc outputPath, str dockerFileContent) {
    writeFile(outputPath, dockerFileContent);
    println("Dockerfile generated successfully at: <outputPath>");
}

Deployment parseDeployment(str inputPath) {
    start[Deployment] parsedDeployment = parse(#start[Deployment], |project://deployment-manager/<inputPath>|);
    return parsedDeployment.top;
}