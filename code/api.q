\d .automl

printing:1b

changePrinting:{printing::not printing}

// @kind function
// @category api
// @fileoverview
// @param filename {sym} Name of the file which can be used to save a log of outputs to file
// @param val      {str} Item that is to be displayed to standard out of any type
// @param nline1   {int} Number of new line breaks before the text that are needed to 'pretty print' the display
// @param nline2   {int} Number of new line breaks after the text that are needed to 'pretty print' the display
printFunction:{[filename;val;nline1;nline2]
  if[not 10h~type val;val:.Q.s[val]];
  newLine1:nline1#"\n";
  newLine2:nline2#"\n";
  printString :newLine1,val,newLine2;
  if[not .automl.printing;
    h:hopen hsym`$filename;
    h printString;
    hclose h;
    :(::)
    ];
  -1 printString;
  }

