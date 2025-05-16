module Runtimes

import Syntax;
import String;
import Helper;
import IO;
import ParseTree;

str resolveRuntime(Runtime r) {
    str name = stripQuotes("<r.name>");
    str version = "";
    list[str] packagesList = [];

    // println(name);
    if (VersionDecl versionDecl <- r.version) {
        version = stripQuotes("<versionDecl.version>");
        // println(insertTabs(1) + "Version: " + version);
    }
    if (PackagesDecl packagesDecl <- r.packages) {
        str packagesStr = "<packagesDecl.packageList>";
        packagesList = parseList(packagesStr);
        // packages = intercalate(" ", packagesList);  // Join with spaces for command line usage
        // println(insertTabs(1) + "Packages: " + toString(packagesList));
    }

    switch (name) {
        case "python": return resolvePythonDependency(version, packagesList);
        case "java": return resolveJavaDependency(version);
        case "influxdb": return resolveInfluxDBDependency(version);
        case "rabbitmq": return resolveRabbitMQDependency(version);
        default: return "alpine:latest"; // Default base image if dependency not recognized
    }
}

str resolvePythonDependency(str version, list[str] packages) {
    // str command = "ENV DEBIAN_FRONTEND=noninteractive \n";
    // command += "RUN apt-get update -y && \\ \n";
    // command += "    apt-get install -y software-properties-common && \\ \n";
    // command += "    add-apt-repository ppa:deadsnakes/ppa -y && \\ \n";
    // command += "    apt-get update -y && \\ \n";
    // command += "    apt-get install python<version> -y && \\ \n";
    // command += "    ln -s /usr/bin/python<version> /usr/bin/python && \\ \n";
    // command += "    apt-get clean\n";

    // if (size(packages) > 0) {
    //     command += "RUN ";
    //     for (int i <- [0 .. size(packages)]) {
    //         command += "apt-get install -y python3-<stripQuotes(packages[i])>";
    //         if (i < size(packages) - 1) {
    //             command += " && ";
    //         }
    //     }
    //     command += "\n";
    // }
    str command = "FROM python:<stripQuotes(version)>\n";
    return command;
}

str resolveJavaDependency(str version) {
    str command = "RUN apt-get update -y && \\ \n";
    command += "    apt-get install -y openjdk-<stripQuotes(version)>-jre-headless && \\ \n";
    command += "    apt-get clean\n";

    return command;
}

str resolveInfluxDBDependency(str version) {
    return "FROM quay.io/influxdb/influxdb:v2.0.3\n";
}

str resolveRabbitMQDependency(str version) {
    return "FROM rabbitmq:3.12-management\n";
}