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
    rel[str, loc] result = {<"<var.name>", var.src> | /Hardware var  := input};

    return summary(l,
        messages = {<src, error("<id> is not defined", src)> | <id, src> <- result}
    );
}
