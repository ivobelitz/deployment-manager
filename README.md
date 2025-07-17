# Deployment Manager

A domain-specific language (DSL) for defining and generating containerized deployments for digital twins. 

## Overview

The Deployment Manager allows you to define deployments for digital twins using a simple, declarative syntax and automatically generates Docker configurations, including Dockerfiles, docker-compose files, and service configuration files.

## Features

- **Declarative Service Definition**: Define services with runtimes, dependencies, and communication patterns
- **Automatic Docker Generation**: Generate Dockerfiles with proper base images and package installations
- **Service Communication**: Model publish/subscribe patterns and HTTP endpoints
- **Configuration Management**: Automatic generation of service configuration files
- **Multi-Hardware Support**: Deploy services across different hardware environments

## Language Syntax

### Basic Structure
```
hardware "machine_name" {
    service "service_name" {
        runtime "python" {
            version = "3.11"
            packages = [
                { name = "numpy", version = "1.24.3" },
                { name = "flask", version = "2.3.2" }
            ]
        }
        sends = ["topic1"]
        receives = ["topic2"]
        ports = [8080]
        executionCommand = "python3 app.py"
    }
}

data {
    "topic1" {
        protocol = "http",
        address = "http://service",
        port = 8080,
        endpoint = "/api/data"
    }
}
```

### Supported Runtimes
- **Python**: Automatic pip package installation with version pinning
- **Java**: OpenJDK installation and configuration
- **InfluxDB**: Time-series database setup
- **RabbitMQ**: Message broker configuration

## Usage

### Generating Deployments

1. **Define your deployment** in a `.dep` file
2. **Generate configurations** using the main function:
   ```rascal
   main("your_deployment.dep")
   ```
3. **Deploy** by copying the generated files to your environment and running:
   ```bash
   docker-compose up
   ``` 

### Enabling syntax highlighting and error checking in VS Code
- Start the LSP server:
```rascal
import Language;
produceLSP();
```

## Generated Artifacts

- **Dockerfiles**: One per service with runtime setup and dependencies
- **docker-compose.yml**: Complete orchestration configuration
- **config.json**: Service-specific configuration files
- **Network configuration**: Automatic service discovery and communication setup

## Example Projects

- `bouncingball.dep`: Simulation service with dashboard frontend
- `incubator.dep`: Digital twin incubator with multiple services. For more details, see the [incubator project](https://github.com/INTO-CPS-Association/example_digital-twin_incubator) and the [associated paper](https://arxiv.org/abs/2102.10390)

## More Details on the Deployment Process
- The *Dockerfiles* and the *config.json* files should be placed in the same directory as the application they deploy.
- The *docker-compose.yml* file should be in the root directory of your project.
- The *config.json* files should be parsed by the application at runtime to configure the services.

## Getting Started

1. Install Rascal MPL
2. Clone this repository
3. Open in VS Code with Rascal extension
4. Define your deployment in a `.dep` file
5. Generate the output artifacts by running the main function:
    ```rascal
    import Main;
    main("your_deployment.dep");
    ```
6. Copy the generated files to their respective directories (see above)
7. Build the Docker images using the generated Dockerfiles:
   ```bash
   docker build -t service_name path/to/service_directory
   ```
6. Use `docker-compose up` to deploy