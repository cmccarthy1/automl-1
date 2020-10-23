\d .automl

// Definitions of the main callable functions used in the application of .automl.saveGraph

// @kind function
// @category saveGraph
// @fileoverview Save down target distribution plot
// @param params   {dict} All data generated during the process
// @param savePath {str} Path where images are to be saved
// return {null} Save target distribution plot to appropriate location
saveGraph.targetPlot:{[params;savePath]
  tts:params[`tts];
  problemTyp:string params[`config;`problemType];
  target:raze tts`ytrain`ytest;
  plotFunc:".automl.saveGraph.i.",problemTyp,"TargetPlot";
  get[plotFunc][target;savePath];
  }



// @kind function
// @category saveGraph
// @fileoverview Save down confusion matrix
// @param params   {dict} All data generated during the process
// @param savePath {str} Path where images are to be saved
// return {null} Save confusion matrix to appropriate location
saveGraph.confusionMatrix:{[params;savePath]
  confMatrix:params[`analyzeModel;`confMatrix];
  modelName :params`modelName;
  saveOpt   :params[`config;`saveopt];
  problemTyp:params[`config;`problemType];
  if[(`class~problemTyp) & saveOpt in 1 2;
    classes:`$string key confMatrix;
    saveGraph.i.displayConfMatrix[value confMatrix;classes;modelName;savePath]
    ];
  }


// @kind function
// @category saveGraph
// @fileoverview Save down impact plot
// @param params   {dict} All data generated during the process
// @param savePath {str} Path where images are to be saved
// return {null} Save impact plot to appropriate location
saveGraph.impactPlot:{[params;savePath]
  saveOpt   :params[`config;`saveopt];
  if[0=saveOpt;:()];
  modelName:params`modelName;
  sigFeats:params`sigFeats;
  impact:params[`analyzeModel;`impact];
  // update impact dictionary to include actual column names
  // instead of just indexes
  updKeys:sigFeats key impact;
  updImpact:updKeys!value impact;
  saveGraph.i.plotImpact[updImpact;modelName;savePath];
  }


// @kind function
// @category saveGraph
// @fileoverview Save down residual plot
// @param params   {dict} All data generated during the process
// @param savePath {str} Path where images are to be saved
// return {null} Save residual plot to appropriate location
saveGraph.residualPlot:{[params;savePath]
  // This is to be added to optimizeParams output
  residuals:params[`analyzeModel;`residuals];
  modelName:params`modelName;
  saveOpt:params[`config;`saveopt];
  problemTyp:params[`config;`problemType];
  if[(`reg~problemTyp)~ saveOpt in 1 2;
    saveGraph.i.plotResiduals[residuals;modelName;savePath]
    ];
  }
