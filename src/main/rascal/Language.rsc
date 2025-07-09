module Language

import util::LanguageServer;
import util::IDEServices;
import ParseTree;
import util::Reflective;
import IO;
import Syntax;
import Helper;


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

void testFunc() {
    println("Hello from the test function!");
    start[Deployment] parsedDeployment = parse(#start[Deployment], |project://deployment-manager/incubator.dep|);
    rel[str, loc] result = {<"<var.name>", var.src> | /Hardware var  := parsedDeployment};

    println(result);
}

Summary mySummarizer(loc l, start[Deployment] input) {
    rel[str, loc] publishes  = {<stripQuotes("<id.topic>"), id.src> | /PublishTopic id  := input};
    rel[str, loc] subscribes = {<stripQuotes("<id.topic>"), id.src> | /SubscribeTopic id := input};

    rel[loc, Message] errors = {<src, error("<id> is published to, but not subscribed to", src)> | <id, src> <- publishes, id notin subscribes<0>};
    errors += {<src, error("<id> is subscribed to, but not published to", src)> | <id, src> <- subscribes, id notin publishes<0>};
    errors += {<src, error("<id> is published to, but not subscribed to", src)> | <id, src> <- publishes, id notin subscribes<0>};

    return summary(l,
        messages = errors
    );
}
