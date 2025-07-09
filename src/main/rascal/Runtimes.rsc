module Runtimes

import Syntax;
import String;
import Helper;
import IO;
import ParseTree;

str resolveRuntime(Runtime r) {
    str name = stripQuotes("<r.name>");
    str version = "";
    list[PackageItem] packagesList = [];

    // println(name);
    if (VersionDecl versionDecl <- r.version) {
        version = stripQuotes("<versionDecl.version>");
        // println(insertTabs(1) + "Version: " + version);
    }
    if (PackagesDecl packagesDecl <- r.packages) {
        packagesList = [pkg | pkg <- packagesDecl.packageList];
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

str resolveRuntimeBaseImage(Runtime r) {
    str name = stripQuotes("<r.name>");
    str version = "";

    if (VersionDecl versionDecl <- r.version) {
        version = stripQuotes("<versionDecl.version>");
    }

    switch (name) {
        case "python": return "FROM python:<stripQuotes(version)>";
        case "java": return "FROM openjdk:<stripQuotes(version)>";
        case "influxdb": return "FROM influxdb:2.0.4-alpine";
        case "rabbitmq": return "FROM rabbitmq:3.12-management";
        default: return "FROM alpine:latest";
    }
}

str resolveRuntimePackages(Runtime r) {
    str name = stripQuotes("<r.name>");
    list[PackageItem] packagesList = [];

    if (PackagesDecl packagesDecl <- r.packages) {
        packagesList = [pkg | pkg <- packagesDecl.packageList];
    }

    switch (name) {
        case "python": return resolvePythonPackages(packagesList);
        case "java": return ""; // Java packages handled differently
        case "influxdb": return ""; // No packages for influxdb
        case "rabbitmq": return ""; // No packages for rabbitmq
        default: return "";
    }
}

str resolvePythonDependency(str version, list[PackageItem] packages) {
    str command = "FROM python:<stripQuotes(version)>\n";
    
    if (size(packages) > 0) {
        command += "RUN pip install ";
        for (int i <- [0 .. size(packages)]) {
            PackageItem pkg = packages[i];
            str pkgName = stripQuotes("<pkg.name>");
            command += pkgName;
            
            // Check if version is specified by looking at the package string representation
            str pkgStr = "<pkg>";
            if (contains(pkgStr, "version")) {
                // Find the version value between quotes after "version ="
                list[str] parts = split("version = \"", pkgStr);
                if (size(parts) > 1) {
                    str versionPart = parts[1];
                    list[str] versionParts = split("\"", versionPart);
                    if (size(versionParts) > 0) {
                        str pkgVersion = versionParts[0];
                        command += "==<pkgVersion>";
                    }
                }
            }
            
            if (i < size(packages) - 1) {
                command += " \\\n    ";
            }
        }
        command += "\n";
    }
    
    return command;
}

str resolveJavaDependency(str version) {
    str command = "RUN apt-get update -y && \\ \n";
    command += "    apt-get install -y openjdk-<stripQuotes(version)>-jre-headless && \\ \n";
    command += "    apt-get clean\n";

    return command;
}

str resolveInfluxDBDependency(str version) {
    str command = "FROM influxdb:2.0.4-alpine\n";
    command += "ENTRYPOINT [\"/entrypoint.sh\"]\n"; 
    return command;
}

str resolveRabbitMQDependency(str version) {
    return "FROM rabbitmq:3.12-management\n";
}

str resolvePythonPackages(list[PackageItem] packages) {
    if (size(packages) == 0) {
        return "";
    }
    
    str command = "RUN pip install ";
    for (int i <- [0 .. size(packages)]) {
        PackageItem pkg = packages[i];
        str pkgName = stripQuotes("<pkg.name>");
        command += pkgName;
        
        // Check if version is specified by looking at the package string representation
        str pkgStr = "<pkg>";
        if (contains(pkgStr, "version")) {
            // Find the version value between quotes after "version ="
            list[str] parts = split("version = \"", pkgStr);
            if (size(parts) > 1) {
                str versionPart = parts[1];
                list[str] versionParts = split("\"", versionPart);
                if (size(versionParts) > 0) {
                    str version = versionParts[0];
                    command += "==<version>";
                }
            }
        }
        
        if (i < size(packages) - 1) {
            command += " \\\n    ";
        }
    }
    return command;
}