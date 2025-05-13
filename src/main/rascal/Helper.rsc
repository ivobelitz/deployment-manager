module Helper

import String;

str stripQuotes(str input) {
  if (input[0] == "\"" && input[size(input) - 1] == "\"") {
    return input[1 .. size(input) - 1];
  }
  return input;
}

list[str] parseList(str packageListStr) {
    // Split the string by commas
    list[str] packagesParts = split(",", packageListStr);
    
    // Process each part to remove quotes and whitespace
    list[str] result = [];
    for (str p <- packagesParts) {
        // Remove whitespace and quotes
        str cleaned = trim(p);
        cleaned = stripQuotes(cleaned);
        result += cleaned;
    }
    
    return result;
}

str insertTabs(int number) {
  str tabs = "";
  for (int i <- [0 .. number * 2]) {
    tabs+=" ";
  }
  return tabs;
}
