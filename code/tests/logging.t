\l automl.q
.automl.loadfile`:init.q
.automl.loadfile`:code/tests/utils.q

.ml.graphDebug:1b

\S 42

.automl.updatePrinting[]

// Create feature and target data
xdata     :([]100?10f;asc 100?1f;100?10)
ydataClass:100?0b
ydataReg  :asc 100?1f

params1   :enlist[`loggingFile]!enlist"logFile"
params2   :enlist[`loggingDir ]!enlist"logDir"
params3   :params1,params2
paramsFail:enlist[`loggingFile]!enlist 123

// Create function to check that appropriate logging file exists depending on 
//  logOption used
checkLogging:{[xdata;ydata;ftype;ptype;params;logOption]
  model:.automl.fit[xdata;ydata;ftype;ptype;params];
  dict:model`modelInfo;
  date:string dict`startDate;
  time:ssr[string dict`startTime;":";"."]
  if[logOption~4;:0Nd~dict`printFile];
  dir:$[logOption<2;
    .automl.path,"/outputs/",date,"/",time,"/log";
    params`loggingDir
    ],"/";
   fileName:$[logOption in 0 2;
     "logFile_",date,"_",time,".txt";
     params[`loggingFile]
    ];
   logPath:dir,fileName;
   $[count hsym`$logPath;
    [system"rm -rf ",logPath;1b];
    0b]
  }


-1"\nTesting appropriate inputs for logging";

// Test when logging is disables
passingTest[checkLogging;(xdata;ydataClass;`normal;`class;(::);4);0b;1b]

// Turn on logging functionality
.automl.updateLogging[]

// Test when logging is enabled
passingTest[checkLogging;(xdata;ydataClass;`normal;`class;(::)   ;0);0b;1b]
passingTest[checkLogging;(xdata;ydataReg  ;`normal;`reg  ;params1;1);0b;1b]
passingTest[checkLogging;(xdata;ydataClass;`normal;`class;params2;2);0b;1b]
passingTest[checkLogging;(xdata;ydataReg  ;`normal;`reg  ;params3;3);0b;1b]

-1"\nTesting inappropriate inputs for logging";

// Create error statement
typeError     :"loggingFile input must be a char array or symbol"
overWriteError:"This logging path already exists, please choose another loggingFile name"

logPath:"logDir/logFile"
h:hopen hsym`$logPath
hclose h

failingTest[.automl.fit;(xdata;ydataClass;`normal;`class;paramsFail);0b;typeError]
failingTest[.automl.fit;(xdata;ydataClass;`normal;`class;params3   );0b;overWriteError]

// Remove any files created
system "rm -r ",logPath;

