module Language

import util::LanguageServer;
import util::IDEServices;
import ParseTree;
import util::Reflective;
import IO;
import Syntax;
import Helper;
import Datamodel;
import String;


set[LanguageService] depContributions() = {
    parsing(parser(#start[Deployment])),
    analysis(mySummarizer, providesImplementations = false)
};

int produceLSP() {
    registerLanguage(
        language(
            pathConfig(srcs=[|project://deployment-manager/src/main/rascal|]),
            "DeploymentManager",
            {"dep"},
            "Language",
            "depContributions"
        )
    );
    return 0;
}


rel[loc, Message] getPortCollisions(start[Deployment] input) {
    Deployment deployment = input.top;
    rel[loc, Message] portCollisions = {};

    for (Hardware h <- deployment.hardwares) {
        list[int] exposedPorts = [];
        for (Service s <- h.services) {
            if (PortsList portsList <- s.ports) {
                for (Int port <- portsList.ports) {
                    int portInt = toInt("<port>");
                    if (portInt in exposedPorts) {
                        println("Port <port> is already exposed by another service in hardware <h.name>");
                        portCollisions += {
                            <port.src, error("Port <portInt> is already exposed by another service", port.src)>
                        };
                    } else {
                        exposedPorts += portInt;
                    }
                }
            }
        }
    }
    return portCollisions;
}

rel[loc, Message] checkUnsupportedRuntime(start[Deployment] input) {
    Deployment deployment = input.top;
    rel[loc, Message] unsupportedRuntimes = {};

    for (Hardware h <- deployment.hardwares) {
        for (Service s <- h.services) {
            if (Runtime r <- s.runtimes) {
                str name = stripQuotes("<r.name>");
                if (name notin ["python", "java", "influxdb", "rabbitmq"]) {
                    unsupportedRuntimes += {
                        <r.src, error("Unsupported runtime: <r.name>", r.src)>
                    };
                }
            }
        }
    }
    return unsupportedRuntimes;
}

Summary mySummarizer(loc l, start[Deployment] input) {
    rel[str, loc] publishes  = {<stripQuotes("<id.topic>"), id.src> | /PublishTopic id  := input};
    rel[str, loc] subscribes = {<stripQuotes("<id.topic>"), id.src> | /SubscribeTopic id := input};

    rel[loc, Message] errors = {<src, error("<id> is published to, but not subscribed to", src)> | <id, src> <- publishes, id notin subscribes<0>};
    errors += {<src, error("<id> is subscribed to, but not published to", src)> | <id, src> <- subscribes, id notin publishes<0>};
    errors += {<src, error("<id> is published to, but not subscribed to", src)> | <id, src> <- publishes, id notin subscribes<0>};

    errors += getPortCollisions(input);
    errors += checkUnsupportedRuntime(input);

    return summary(l,
        messages = errors
    );
}
