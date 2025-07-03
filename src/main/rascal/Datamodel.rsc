module Datamodel

data File = file(str content, str outputDir, str fileName);

data DataPoint = dataPoint(str protocol, str host, int port);
