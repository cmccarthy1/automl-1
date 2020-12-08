\d .automl

// Error presentation

// @kind function
// @category dataCheckUtility
// @fileoverview print to standard out flagging the removal of inappropriate columns
// @param clist {sym[]} list of all columns in the dataset
// @param slist {sym[]} sublist of columns appropriate for the use case
// @param typ   {sym} Feature extraction type being implemented
// @param cfg   {dict} Configuration information assigned by the user and related to the current run
// @return      {(Null;stdout)} generic null if all columns suitable, appropriate print out
//   in the case there are outstanding issues
dataCheck.i.errColumns:{[clist;slist;typ;cfg]
  if[count[clist]<>count slist;
    errString:utils.printDict[`errColumns],string typ;
    removedCols:", "sv string clist where not clist in slist;
    cfg[`logFunc] errString,": ",removedCols
    ]
  }

// Parameter retrieval functionality

// @kind function
// @category dataCheckUtility
// @fileoverview retrieve default parameters and update with custom information
// @param feat    {tab} The feature data as a table
// @param cfg     {dict} Configuration information assigned by the user and related to the current run
// @param default {dict} Default dictionary which may need to be updated
// @param ptyp    {sym} problem type being solved (`nlp/`normal/`fresh)
/. returns > configuration dictionary modified with any custom information
dataCheck.i.getCustomConfig:{[feat;cfg;default;ptyp]
  dict:$[(typ:type cfg)in 10 -11 99h;
      [if[10h~typ ;cfg:dataCheck.i.getData[cfg;ptyp]];
       if[-11h~typ;cfg:dataCheck.i.getData[;ptyp]$[":"~first cfg;1_;]cfg:string cfg];
       $[min key[cfg]in key default;
         default,cfg;
         '`$"Inappropriate key provided for configuration input"
        ]
      ];
      not any cfg;d;
      '`$"cfg must be passed the identity `(::)`, a filepath to a parameter flatfile",
         " or a dictionary with appropriate key/value pairs"
    ];
  if[ptyp=`fresh;
     aggcols:dict`aggregationColumns;
     dict[`aggregationColumns]:$[100h~typagg:type aggcols;aggcols feat;
                   11h~abs typagg;aggcols;
                   '`$"aggcols must be passed function or list of columns"
                   ]
  ];
  dict,enlist[`tensorFlow]!enlist 1~checkimport[0]
  }

// @kind function
// @category dataCheckUtility
// @fileoverview retrieve a json flatfile from disk 
// @param  fileName {char[]} name of the file from which the dictionary is being extracted
// @param  ptype    {sym} The problem type being solved(`nlp`normal`fresh)
// @return          {dict} configuration dictionary retrieved from a flatfile
dataCheck.i.getData:{[fileName;ptype]
  customFile:cli.i.checkCustom fileName;
  customJson:.j.k raze read0 `$customFile;
  (,/)cli.i.parseParameters[customJson]each(`general;ptype)
  }

// @kind function
// @category dataCheckUtility
// @fileoverview parse the hyperparameter flat file
// @param fileName {char[]} name of the file to be parsed
// @param filePath {char[]} file path to the hyperparmeter file relative to `.automl.path`
// @returns  > dictionary mapping model name to possible hyper parameters 
dataCheck.i.paramParse:{[fileName;filePath]
  key[k]!(value@){(!).("S=;")0:x}each k:(!).("S*";"|")0:hsym`$.automl.path,filePath,fileName
  }

// Save path generation functionality

// @kind function
// @category dataCheckUtility
// @fileoverview create the folders that are required for the saving of the config,
//   models, images and reports
// @param cfg {dict} Configuration information assigned by the user and related to the current run
// @return {dict} File paths relevant for saving reports/config etc to file, both as full path format 
//   and truncated for use in outputs to terminal
dataCheck.i.pathConstruct:{[cfg]
  names:`config`models;
  if[cfg[`saveOption]=2;names:names,`images`report];
  pname:$[`~cfg`saveModelName;dataCheck.i.dateTimePath;dataCheck.i.customPath]cfg;
  paths:pname,/:string[names],\:"/";
  dictNames:`$string[names],\:"SavePath";
  (dictNames!paths),enlist[`mainSavePath]!enlist pname
  }

// @kind function
// @category dataCheckUtility
// @fileoverview Construct save path using date and time of the run
// @param cfg {dict} Configuration information assigned by the user and related to the current run
// @return {str} Path constructed based on run date and time 
dataCheck.i.dateTimePath:{[cfg]
  date:string cfg`startDate;
  time:string cfg`startTime;
  path,"/",dataCheck.i.dateTimeStr["outputs/",date,"/run_",time,"/"]
  }

// @kind function
// @category dataCheckUtility
// @fileoverview Construct save path using custom model name
// @param cfg {dict} Configuration information assigned by the user and related to the current run
// @return {str} Path constructed based on user defined custom model name
dataCheck.i.customPath:{[cfg]
  modelName:cfg[`saveModelName];
  modelName:$[10h=type modelName;modelName;
   -11h=type modelName;string modelName;
   '"unsupported input type, model name must be a symbol atom or string"];
  filePath:path,"/outputs/namedModels/",modelName,"/";
  filePath
  }

// @kind function
// @category dataCheckUtility
// @fileoverview Construct saved logged file path
// @param cfg {dict} Configuration information assigned by the user and related to the current run
// @return {str} Path constructed to log file based on user defined paths
dataCheck.i.logging:{[cfg]
  if[0~cfg`saveOption;
    if[`~cfg`loggingDir;
      -1"\nIf saveOption is 0 and loggingDir is not defined, logging is disabled.\n";
    .automl.utils.printing:1b;.automl.utils.logging:0b;:cfg]];
  if[10h<>type cfg`loggingDir;string cfg`loggingDir]
  printDir:$[`~cfg`loggingDir;
    cfg[`mainSavePath],"/log/";
    [typeLogDir:type cfg`loggingDir;
     loggingDir:$[10h=typeLogDir;;
       -11h=typeLogDir;string;
       '"type must be a char array or symbol"]cfg`loggingDir;
    path,"/",loggingDir,"/"]
    ];
  if[`~cfg`loggingFile;
    date:string cfg`startDate;
    time:string cfg`startTime;
    logStr:"logFile_",date,"_",time,".txt";
    cfg[`loggingFile]:dataCheck.i.dateTimeStr logStr];
  typeLoggingFile:type cfg[`loggingFile];
  loggingFile:$[10h=typeLoggingFile;;
    -11h=typeLoggingFile;string;
    '"loggingFile input must be a char array or symbol"]cfg`loggingFile;
  cfg[`printFile]:printDir,loggingFile;
  cfg
  }

// @kind function
// @category dataCheckUtility
// @fileoverview Construct date time string path in appropriate format
// @param strPath {str} Date time path string
// @return {str} Date and time path converted to appropriate format
dataCheck.i.dateTimeStr:{[strPath]ssr[strPath;":";"."]}

// @kind function
// @category dataCheckUtility
// @fileoverview Check if directories to be created already exist
// @param cfg {dict} Configuration information assigned by the user and related to the current run
// @return {null;err} Error if logfile or savePath already exists
dataCheck.i.fileNameCheck:{[cfg]
  ignore:utils.ignoreWarnings;
  if[cfg`overWriteFiles;ignore:2];
  mainFileExists:$[0<cfg`saveOption;count key hsym`$cfg`mainSavePath;0];
  loggingExists :$[utils.logging;count key hsym`$cfg`printFile;0];
  dataCheck.i.delFiles[cfg;ignore;mainFileExists;loggingExists];
  dataCheck.i.printWarning[cfg;ignore;mainFileExists;loggingExists]
  }
 

// @kind function
// @category dataCheckUtility
// @fileoverview Delete any previous save paths and logging paths if warnings are to be ignored
// @param cfg            {dict} Configuration information assigned by the user and related to the current run
// @param ignore         {int}  The ignoreWarnings options chosen (0-2)
// @param mainFileExists {bool} Whether the savePath exists if saveOption is greater than 0
// @param loggingExists  {bool} Whether the logging path exists if logging option is chosen
// @return {null} Delete save paths and logging files
dataCheck.i.delFiles:{[cfg;ignore;mainFileExists;loggingExists]
  if[ignore=0;:()];
  if[mainFileExists;system"rm -rf ",cfg[`mainSavePath]];
  if[loggingExists;system"rm -rf ",cfg[`printFile]];
  }


// @kind function
// @category dataCheckUtility
// @fileoverview If savePath and logging already exist, give warning or error out depening on
//  ignoreWarning option
// @param cfg            {dict} Configuration information assigned by the user and related to the current run
// @param ignore         {int}  The ignoreWarnings options chosen (0-2)
// @param mainFileExists {bool} Whether the savePath exists if saveOption is greater than 0
// @param loggingExists  {bool} Whether the logging path exists if logging option is chosen
// @return {null;err} Error if logfile or savePath already exists or give warning
dataCheck.i.printWarning:{[cfg;ignore;mainFileExists;loggingExists]
  if[ignore=2;:()];
  if[mainFileExists;
      dataCheck.i.warningOption[cfg;ignore] utils.printWarnings[`savePathExists]ignore];
  if[loggingExists;
       dataCheck.i.warningOption[cfg;ignore] utils.printWarnings[`loggingPathExists]ignore];
  }


// @kind function
// @category dataCheckUtility
// @fileoverview How the warning should be handled depending on the ignoreWarning
//  option chosen 
// @param cfg    {dict} Configuration information assigned by the user and related to the current run
// @param ignore {int} IgnoreWarning attribute between 0-2 descibing how to handle warnings
// @return {err;str} Print warning to screen/log file or error out
dataCheck.i.warningOption:{[cfg;ignore]
  $[ignore=0;{'x};ignore=1;cfg`logFunc;]
  }
