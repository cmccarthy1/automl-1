\d .automl

// Definitions of the main callable functions used in the application of runModels

// @kind function
// @category runModels
// @fileoverview Set value of random seed for reproducability
// @param cfg {dict} configuration information relating to the current run of AutoML
// @return {Null} Value of seed is set
runModels.setSeed:{[cfg]
  system"S ",string cfg`seed;
  }

// @kind function
// @category runModels
// @fileoverview Apply train test split to keep holdout for feature impact plot and testing of vanilla best model
// @param cfg  {dict} Configuration information relating to the current run of AutoML
// @param tts  {dict} Feature and target data split into training and testing set
// @return {dict} Training and holdout split of data
runModels.holdoutSplit:{[cfg;tts]
  ttsFunc:get cfg`tts;
  ttsFunc[tts`xtrain;tts`ytrain;cfg`hld]
  }

// @kind function
// @category runModels
// @fileoverview Seeded cross-validation function, designed to ensure that models will be consistent
//  from run to run in order to accurately assess the benefit of updates to parameters
// @param tts  {dict} Feature and target data split into training and testing set
// @param cfg  {dict} Configuration information relating to the current run of AutoML
// @param mdl  {tab}  Model to be applied to feature data
// @return {(bool[];float[])} Predictions and associated actual values for each cross validation fold
runModels.xValSeed:{[tts;cfg;mdl]
  xTrain:tts`xtrain;
  yTrain:tts`ytrain;
  scoreFunc:cfg[`prf]mdl`minit;
  seedModel:`seed~mdl`seed;
  isSklearn:`sklearn~mdl`lib;
  // Seed handled differently for sklearn and keras  
  seed:$[not seedModel;
      ::;
    isSklearn;
      enlist[`random_state]!enlist cfg`seed;
      (cfg`seed;mdl`typ)
      ];
  $[seedModel&isSklearn;
    // Grid search required to incorporate the random state definition
    [gsFunc:get cfg[`gs]0;
     numFolds:cfg[`gs]1;
     numReps:cfg[`gs]2;
     first value gsFunc[numFolds;numReps;xTrain;yTrain;scoreFunc;seed;0]
     ];
    // Otherwise a vanilla cross validation is performed
    [xvFunc:get cfg[`xv]0;
     numFolds:cfg[`xv]1;
     numReps:cfg[`xv]2;
     xvFunc[numFolds;numReps;xTrain;yTrain;scoreFunc seed]
     ]
    ]
  }
   
// @kind function
// @category runModels
// @fileoverview Extract the scoring function to be applied for model selection
// @param cfg   {dict} Configuration information relating to the current run of AutoML
// @param mdls  {tab}  Models to be applied to feature data
// @return {<} Scoring function appropriate to the problem being solved
runModels.scoringFunc:{[cfg;mdls]
  problemType:$[`reg in distinct mdls`typ;`reg;`class];
  scoreFunc:cfg[`scf]problemType;
  -1"\nScores for all models, using ",string scoreFunc;
  scoreFunc
  }

// @kind function
// @category runModels
// @fileoverview Order average predictions returned by models
// @param mdls        {tab}  Models to be applied to feature data
// @param scoreFunc   {<} Scoring function applied to predictions
// @param predictions {(bool[];float[])} Predictions made by model
// @return {dict} Scores returned by each model in appropriate order 
runModels.orderModels:{[mdls;scoreFunc;predicts]
  orderFunc:get string first runModels.i.txtParse[`score;"/code/customization/"]scoreFunc;
  avgScore:avg each scoreFunc .''predicts;
  scoreDict:mdls[`model]!avgScore;
  orderFunc scoreDict
  }

// @kind function
// @category runModels
// @fileoverview Fit best model on holdout set and score predictions
// @param scores    {dict} Scores returned by each model
// @param tts       {dict} Feature and target data split into training and testing set
// @param mdls      {tab}  Models to be applied to feature data
// @param scoreFunc {<} Scoring function applied to predictions
// @param cfg       {dict} Configuration information assigned by the user and related to the current run
// @return {dict} Fitted model and scores along with time taken 
runModels.bestModelFit:{[scores;tts;mdls;scoreFunc;cfg]
  holdoutTimeStart:.z.T;
  bestModel:first key scores;
  -1"\nBest scoring model = ",string bestModel;
  modelFitStart:.z.T;
  modelLib:first exec lib from mdls where model=bestModel;
  fitScore:$[modelLib in key models;
    runModels.i.customModel[bestModel;tts;mdls;scoreFunc;cfg];
    runModels.i.sklModel[bestModel;tts;mdls;scoreFunc]
    ];
  holdoutTime:.z.T-holdoutTimeStart;
  returnDict:`holdoutTime`bestModel!holdoutTime,bestModel;
  fitScore,returnDict
  }

// @kind function
// @category runModels
// @fileoverview Create dictionary of meta data used
// @param holdoutRun {dict} Information from fitting and scoring on the
//  holdout set
// @param scores    {dict} Scores returned by each model
// @param scoreFunc {<} Scoring function applied to predictions
// @param xValTime  {T} Time taken to apply xval functions to data
// @return {dict} Metadata to be contained within the end reports
runModels.createMeta:{[holdoutRun;scores;scoreFunc;xValTime]
  metaKeys:`holdoutScore`modelScores`metric`xValTime`holdoutTime;
  metaVals:(holdoutRun`score;scores;scoreFunc;xValTime;holdoutRun`holdoutTime);
  metaKeys!metaVals
  }

// @kind function
// @category runModels
// @fileoverview Defaulted fitting and prediction functions for automl cross-validation 
//  and grid search, both models fit on a training set and return the predicted scores based 
//  on supplied scoring function.
// @param func {<} Function taking in parameters and data as input, returns appropriate score
// @param hyperParam {dict} hyperparameters on which to complete hyperparameter search
// @data {float[]} data as a ((xtrn;ytrn);(xval;yval)), this structure is defined from the data
// @return {(bool[];float[])} Value predicted on the validation set and the true value 
runModels.fitPredict:{[func;hyperParam;data]
  predicts:$[0h~type hyperParam;
    func[data;hyperParam 0;hyperParam 1];
    @[.[func[][hyperParam]`:fit;data 0]`:predict;data[1]0]`
    ];
  (predicts;data[1]1)
  }
