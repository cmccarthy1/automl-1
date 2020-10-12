\d .automl

// Utility functions for runmodels

// @kind function
// @category runModelsUtility
// @fileoverview Extraction of an appropriately valued dictionary from a non complex flat file
// @param nameMap  {sym} Name mapping to appropriate text file
// @param filePath {str} File path relative to .automl.path
// @return {dict} Parsed from an appropriate flat file
runModels.i.txtParse:{[nameMap;filePath]
  fileName:`$path,filePath,runModels.i.files nameMap;
  runModels.i.readFile each(!).("S*";"|")0:hsym fileName
  }


// @kind function
// @category runModelsUtility
// @fileoverview Extraction of data from a file
// @param filePath {str} File path from which to extract the data from 
// @return {dict} parsed from file
runModels.i.readFile:{[filePath]
  key(!).("S=;")0:filePath
  }


// @kind function
// @category runModelsUtility
// @fileoverview Fit and score custom model to holdout set
// @param bestModel {sym} The best scorinng model from xval
// @param tts       {dict} Feature and target data split into training and testing set
// @param mdls      {tab}  Models to be applied to feature data
// @param scoreFunc {<} Scoring metric applied to evaluate the model
// @param cfg       {dict} Configuration information assigned by the user and related to the current run
// @return {dict} The fitted model along with the predictions
runModels.i.customModel:{[bestModel;tts;mdls;scoreFunc;cfg]
  if[bestModel~`multikeras;
    tts[`ytrain`ytest]:models.i.npArray flip@'value@'.ml.i.onehot1 each tts`ytrain`ytest];
  funcName:string first exec fnc from mdls where model=bestModel;
  libName:string first exec lib from mdls where model=bestModel;
  customStr:".automl.models.",libName,".",funcName,".";
  model:get[customStr,"model"][tts;cfg`seed];
  fitModel:get[customStr,"fit"][tts;model];
  predicts:get[customStr,"predict"][tts;fitModel];
  score:scoreFunc[;tts`ytest]predicts;
  `model`score!(fitModel;score)
  }

// @kind function
// @category runModelsUtility
// @fileoverview Fit and score sklearn model to holdout set
// @param bestModel {sym} The best scorinng model from xval
// @param tts       {dict} Feature and target data split into training and testing set
// @param mdls      {tab}  Models to be applied to feature data
// @param scoreFunc {<} Scoring metric applied to evaluate the model
// @return {dict} The fitted model along with the predictions
runModels.i.sklModel:{[bestModel;tts;mdls;scoreFunc]
  model:(first exec minit from mdls where model=bestModel)[][];
  model[`:fit][;]. tts`xtrain`ytrain;
  predicts:model[`:predict][tts`xtest]`;
  score:scoreFunc[;tts`ytest]predicts;
  `model`score!(model;score)
  }

// @kind function
// @category runModelsUtility
// Text files that can be parsed from within the models folder
runModels.i.files:`class`reg`score!("models/classmodels.txt";"models/regmodels.txt";"scoring/scoring.txt")