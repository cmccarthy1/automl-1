\d .automl

// The purpose of this file is to house  utilities that are useful across more
// than one node or as part of the automl run/new/savedefault functionality and graph

// @kind function
// @category utility
// @fileoverview Extraction of an appropriately valued dictionary from a non complex flat file
// @param nameMap  {sym} Name mapping to appropriate text file
// @param filePath {str} File path relative to .automl.path
// @return {dict} Parsed from an appropriate flat file
utils.txtParse:{[nameMap;filePath]
  fileName:`$path,filePath,utils.files nameMap;
  utils.readFile each(!).("S*";"|")0:hsym fileName
  }

// @kind function
// @category utility
// @fileoverview Extraction of data from a file
// @param filePath {str} File path from which to extract the data from 
// @return {dict} parsed from file
utils.readFile:{[filePath]
  key(!).("S=;")0:filePath
  }

// @kind function
// @category utility
// Text files that can be parsed from within the models folder
utils.files:`class`reg`score!("models/modelConfig/classmodels.txt";"models/modelConfig/regmodels.txt";"scoring/scoring.txt")

// @kind function
// @category utility
//List of models to exclude
utils.excludeList:`GaussianNB`LinearRegression;

// @kind function
// @category Utility
// @fileoverview Defaulted fitting and prediction functions for automl cross-validation 
//  and grid search, both models fit on a training set and return the predicted scores based 
//  on supplied scoring function.
// @param func {<} Function taking in parameters and data as input, returns appropriate score
// @param hyperParam {dict} hyperparameters on which to complete hyperparameter search
// @data {float[]} data as a ((xtrn;ytrn);(xval;yval)), this structure is defined from the data
// @return {(bool[];float[])} Value predicted on the validation set and the true value 
utils.fitPredict:{[func;hyperParam;data]
  predicts:$[0h~type hyperParam;
    func[data;hyperParam 0;hyperParam 1];
    @[.[func[][hyperParam]`:fit;data 0]`:predict;data[1]0]`
    ];
  (predicts;data[1]1)
  }

// @kind function
// @category Utility
// @fileoverview Load function from q. If function not found, try python 
// @param funcName {sym} Name of function to retrieve
// @return {function} Loaded function
utils.qpyFuncSearch:{[funcName]
  func:@[get;funcName;()];
  $[()~func;.p.get[funcName;<];func]
  }

// @kind function
// @category Utility
// @fileoverview Load NLP library if requirements met
// @params {null}
// @return {null} Library loaded if requirements met or statement printed to terminal
utils.loadNLP:{
  $[(0~checkimport[3])&(::)~@[{system"l ",x};"nlp/nlp.q";{0b}];
    .nlp.loadfile`:init.q;
    -1"Requirements for NLP models are not satisfied. gensim must be installed. NLP module will not be available.";
    ]
  }

// @kind function
// @category Utility
// @fileoverview Used throughout the library to convert linux/mac file names to windows equivalent
// @param path {str} the linux 'like' path
// @retutn {str} path modified to be suitable for windows systems
utils.ssrWindows:{[path]
  $[.z.o like "w*";ssr[path;"/";"\\"];path]
  }

// Python plot functionality
utils.plt:.p.import`matplotlib.pyplot;

// @kind function
// @category Utility
// @fileoverview Used throughout when printing directory of saved objects.
//  this is to keep linux/windows consistent
// @param path {str} the linux 'like' path
// @retutn {str} path modified to be suitable for windows systems
utils.ssrsv:{[path]
  ssr[path;"\\";"/"]
  }

// @kind function
// @category Utility
// @fileoverview Split data into train and testing set without shuffling
// @param feat {tab}   The feature data as a table 
// @param tgt  {num[]} Numerical vector containing target data
// @param size {float} Proportion of data to be left as testing
// @retutn {dict}  Data separated into training and testing sets
utils.ttsNonShuff:{[feat;tgt;size]
  `xtrain`ytrain`xtest`ytest!raze(feat;tgt)@\:/:(0,floor n*1-size)_til n:count feat
  }

// @kind function
// @category Utility
// @fileoverview Return column value based on best model
// @param mdls      {tab} Models to be applied to feature data
// @param modelName {sym} The name of the model
// @param col       {sym} Column to search
// @return {sym} Column value
utils.bestModelDef:{[mdls;modelName;col]
  first?[mdls;enlist(=;`model;enlist modelName);();col]
  }

// @kind function
// @category automl
// @fileoverview Retrieve the feature and target data from a user defined
//   json file containing data retrieval information.
// @param method {dict} A dictionary outlining the methods to be used for
//   retrieval of the command line data. i.e. `featureData`targetData!("csv";"ipc")
// @return       {dict} A dictionary containing the feature and target data
//   retrieved based on user instructions
utils.getCommandLineData:{[method]
  methodSpecification:cli.input`retrievalMethods;
  dict:key[method]!methodSpecification'[value method;key method];
  if[count idx:where `ipc=method;dict[idx]:("J";"c";"c")$/:3#'dict[idx]];
  dict:dict,'([]typ:value method);
  featureData:.ml.i.loaddset dict`featureData;
  featurePath:dict[`featureData]utils.dataType method`featureData;
  targetPath :dict[`targetData]utils.dataType method`targetData;
  targetName :`$dict[`targetData]`targetColumn;
  // If the data retrieval methods are the same for target and feature
  // only load the data once and retrieve the target from the table otherwise
  // retrieve the target data using i.loaddset
  data:$[featurePath~targetPath;
      (flip targetName _ flip featureData;featureData targetName);
      (featureData;.ml.i.loaddset[dict`targetData]$[`~targetName;::;targetName])
      ];
  `features`target!data
  }

// @kind function
// @category Utility
// @fileoverview Create the prediction function used when applying the model to new data
//   this function is used as the '`predict' value off the fit model and retrieved model
//   as a projection with feature data provided on calls to the function.
// @param config {dict} Configuration information related to a run of automl. This contains
//   information about the feature extraction procedure and the embedPy model (sklearn/keras)
//   used to make predictions
// @param feats  {tab}   Feature data based on which predictions are to be made.
// @returns      {num[]} Predictions
utils.generatePredict:{[config;feats]
  bestModel:config`bestModel;
  feats:utils.featureCreation[config;feats];
  modelLibrary:config`modelLib;
  $[`sklearn~modelLibrary;bestModel[`:predict;<]feats;
    `keras~modelLibrary;
    [feats:enlist[`xtest]!enlist feats;
     get[".automl.models.keras.",(neg[5]_string config`modelName),".predict"][feats;bestModel]];
    '"NotYetImplemented"]
  }

// @kind function
// @category Utility
// @fileoverview Apply feature extraction/creation and feature selection on provided data
//   for based on a previous run
// @param config {dict} Configuration information related to a run of automl. This contains
//   information about the feature extraction procedure
// @param feats  {tab} Feature data based on which predictions are to be made.
// @returns      {tab} Table with feature extraction procedures applied to
//   retrieve appropriate features
utils.featureCreation:{[config;feats]
  sigFeats     :config`sigFeats;
  extractType  :config`featExtractType;
  if[`nlp  ~extractType;config[`savedWord2Vec]:1b];
  if[`fresh~extractType;
    relevantFuncs:raze`$distinct{("_" vs string x)1}each sigFeats;
    appropriateFuncs:1!select from 0!.ml.fresh.params where f in relevantFuncs;
    config[`functions]:appropriateFuncs];
  feats:dataPreprocessing.node.function[config;feats;config`symEncode];
  feats:featureCreation.node.function[config;feats]`features;
  if[not all newFeats:sigFeats in cols feats;
    newColumns:sigFeats where not newFeats;
    feats:sigFeats xcols flip flip[feats],newColumns!((count newColumns;count feats)#0f),()];
  flip value flip sigFeats#"f"$0^feats
  }

// @kind function
// @category Utility
// @fileoverview Retrieve model from disk generated previously from
// @param config {dict} Configuration information related to a run of automl. This contains
//   information about the feature extraction procedure
// @returns      {tab} Table with feature extraction procedures applied to
//   retrieve appropriate features
utils.loadModel:{[config]
  modelLibrary:config`modelLib;
  loadFunction:$[modelLibrary~`sklearn;
    .p.import[`joblib][`:load];
    modelLibrary~`keras;
    $[0~checkimport[0];.p.import[`keras.models][`:load_model];'"Keras model could not be loaded"]
   ];
  modelFile:config[`modelsSavePath],$[modelLibrary~`sklearn;
    string[config`modelName];
    modelLibrary~`keras;string[config`modelName],".h5";
    '"Unsupported model type provided"];
  loadFunction modelFile
  }

// @kind function
// @category Utility
// @fileoverview Generate the path to a model based on user defined dictionary input.
//   This assumes no knowledge of the configuration rather this is the gateway to
//   retrieve the configuration and models
// @param dict {dict}   Configuration detailing where to retrieve the model.
//   This must contain one of the following:
//     1. Dictionary mapping `startDate`startTime to the date and time associated with the model run
//     2. Dictionary mapping `savedModelName to a model named for a run previously executed
// @returns    {char[]} Path to the model detail information
utils.modelPath:{[dict]
  pathStem:path,"/outputs/";
  keyDict:key dict;
  pathStem,$[all `startDate`startTime in keyDict;
    $[all(-14h;-19h)=type each dict`startDate`startTime;
      ssr[string[dict`startDate],"/run_",string[dict`startTime],"/";":";"."];
      '"Types provided for date/time retrieval must be a date and time respectively"];
    `savedModelName in keyDict;
    $[10h=type dict`savedModelName;
      "namedModels/",dict[`savedModelName],"/";
      '"Types provided for model name based retrieval must be a string"];
    '"A user must define model start date/time or model name.";
    ]
  }

// @kind function
// @category Utility
// @fileoverview Dictionary outlining the keys which must be equivalent for data retrieval
//   in order for a dataset not to be loaded twice (assumes tabular return under equivalence)
utils.dataType:`ipc`binary`csv!(`port`select;`directory`fileName;`directory`fileName)
