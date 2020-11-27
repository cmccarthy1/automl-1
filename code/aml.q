\d .automl

// Automated machine learning, generation of optimal models, running on new data and 
// generation of default flatfile configurations

// @kind function
// @category automl 
// @fileoverview AutoML pipeline application on training and testing datasets
//   applying cross validation and hyperparameter search methods across a range
//   of machine learning models. Saves a reports, models, metadata information and
//   graphics for oversight purposes. 
// @param  graph  {dict} fully connected nodes and edges of a the graph used for the 
//   application of the AutoML pipeline following the definition outline 
//   in `graph/Automl_Graph.png`
// @param  xdata  {(dict;table)} unkeyed tabular feature data or dictionary outlining
//   the instructions with which to retrieve the tabular feature data in
//   accordance with `.ml.i.loaddset`
// @param  ydata  {(dict;#any[])} Target vector of any type or dictionary outlining 
//   the instructions with which to retrieve the target data in accordance with `.ml.i.loaddset`
// @param  ftype  {sym} Feature extraction type (`nlp/`normal/`fresh)
// @param  ptype  {sym} Problem type being solved (`reg/`class)
// @param  params {(dict;char[];::)} One of 
//   1. Path relative to `.automl.path` pointing to a user defined flatfile for 
//      modifying default parameters,  
//   2. Dictionary containing the aspects of default behaviour which is to be overwritten
//   3. Null(::) allowing a user to run the AutoML framework using default parameters 
// @return        {table} The full graph executed to completeness or with a diagnostic error
//   highlight to the user.
run:{[graph;xdata;ydata;ftype;ptype;params]
  // Retrieve default parameters parsed at startup and append necessary
  // information for further parameter retrieval
  modelName:enlist[`saveModelName]!enlist`$problemDict`modelName;
  defaultParams:paramDict[`general],paramDict[ftype],modelName;
  automlConfig :defaultParams,$[type[params]in 10 -11h;enlist[`configPath]!enlist params;
    99h=type params;params;
    params~(::);()!();
    '"Unsupported input type for 'params'"
    ];
  automlConfig:automlConfig,`featExtractType`problemType`startDate`startTime!(ftype;ptype;.z.D;.z.T);
  // Default = accept data from process. Overwritten if dictionary input
  xdata:$[99h=type xdata;xdata;`typ`data!(`process;xdata)];
  ydata:$[99h=type ydata;ydata;`typ`data!(`process;ydata)];
  graph:.ml.addCfg[graph;`automlConfig     ;automlConfig];
  graph:.ml.addCfg[graph;`featureDataConfig;xdata];
  graph:.ml.addCfg[graph;`targetDataConfig ;ydata];
  graph:.ml.connectEdge[graph;`automlConfig     ;`output;`configuration;`input];
  graph:.ml.connectEdge[graph;`featureDataConfig;`output;`featureData  ;`input];
  graph:.ml.connectEdge[graph;`targetDataConfig ;`output;`targetData   ;`input];
  .ml.execPipeline .ml.createPipeline[graph];
  automlConfig`startDate`startTime
  }[graph]

// @kind function
// @category automl
// @fileoverview Generate a new json flat file for use in application of AutoML
//   for command line or as an alternative to the param file in .automl.run.
// @param  fileName {str/sym/hsym} Name to be associated with the json file
//   to be generated in 'code/customization/configuration/customConfig'.
// @return          {::} Returns generic null on successful invocation and saves
//   a copy of the file 'code/customization/configuration/default.json' to the 
//   appropriate named file.
newDefault:{[fileName]
  fileNameType:type fileName;
  fileName:$[10h=fileNameType;fileName;
    -11h=fileNameType;
    $[":"~first strFileName;1_;]strFileName:string fileName;
    '`$"fileName must be string, symbol or hsym"];
  fileName:raze[path],"/code/customization/configuration/customConfig/",fileName;
  filePath:hsym`$utils.ssrWindows fileName;
  if[not ()~key filePath;
    '"A configuration of this name already exists at:",fileName
    ];
  defaultConfig:read0 `$path,"/code/customization/configuration/default.json";
  h:hopen filePath;
  {x y,"\n"}[h]each defaultConfig;
  hclose h;
  }

// @kind function
// @category automl
// @fileoverview Run the AutoML framework based on user provided custom json flat files.
//   This function is triggered when executing the automl.q file and invoking the functionality
//   is based on the presence of an appropriately named configuration file and presence of the
//   run command line argument on session startup i.e.
//   $ q automl.q -config myconfig.json -run
//   This function takes no parameters as input an does not returns any artifacts to be used 
//   in process. Instead it executes the entirety of the automl pipeline saving the report/model
//   images and metadata to disc and exits the process.
runCommandLine:{[]
  ptype:`$problemDict`problemType;
  ftype:`$problemDict`featureExtractionType;
  dataRetrieval:`$problemDict`dataRetrievalMethod;
  if[any(raze ptype,ftype,raze dataRetrieval)=\:`;
    '"`problemType,`featureExtractionType and `dataRetrievalMethod must all be defined"
  ];
  data:utils.getCommandLineData[dataRetrieval];
  run[;;ftype;ptype;::]. data`features`target;
  }
