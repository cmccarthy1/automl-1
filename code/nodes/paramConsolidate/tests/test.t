\l automl.q
.automl.loadfile`:init.q

// The following utilities are used to test that a function is returning the expected
// error message or data, these functions will likely be provided in some form within
// the test.q script provided as standard for the testing of q and embedPy code

// @kind function
// @category tests
// @fileoverview Ensure that a test that is expected to pass, 
//   does so with an appropriate return
// @param function {(func;proj)} The function or projection to be tested
// @param data {any} The data to be applied to the function as an individual item for
//   unary functions or a list of variables for multivariant functions
// @param applyType {boolean} Is the function to be applied unary(1b) or multivariant(0b)
// @param expectedReturn {string} The data expected to be returned on 
//   execution of the function with the supplied data
// @return {boolean} Function returned the appropriate output (1b), function failed 
//   or executed with incorrect output (0b)
passingTest:{[function;data;applyType;expectedReturn]
  // Is function to be applied unary or multivariant
  applyType:$[applyType;@;.];
  functionReturn:applyType[function;data];
  expectedReturn~functionReturn
  }

// Generate preProcParams dictionary
preProcParamsKeys:`config`dataDescription`symMap`creationTime`sigFeats`featModel
preProcParamsVals:(()!();([]col1:10?10;col2:10?1f);`freq`ohe!`col1`col2;1?1t;`feat1`feat2;.p.import`gensim)
preProcParamDict :preProcParamsKeys!preProcParamsVals

// Generate data for prediction params

// Feature Data
feats:100 3#300?10f

// Target values
tgtClass:100?0b

// Target data split into train and testing sets
ttsFeat :        `xtrain`xtest!(80#feats   ;-20#feats)
ttsClass:ttsFeat,`ytrain`ytest!(80#tgtClass;-20#tgtClass)

// Random Forest best model
randomForestFit:{[mdl;train;test].p.import[`sklearn.ensemble][mdl][][`:fit][train;test]}
randomForestMdl:randomForestFit[`:RandomForestClassifier;;] . ttsClass`xtrain`ytrain

// Generate meta data from running models
modelMetaKeys:`holdoutScore`modelScores`metric`xValTime`holdoutTime
modelMetaVals:(1?100f;`mdl1`mdl2`mdl3!3?100f;`accuracy;1?1t;1?1t)
modelMetaData:modelMetaKeys!modelMetaVals

// Generate prediction params dictionary
predictionStoreKeys:`bestModel`hyperParams`testScore`predictions`modelMetaData
predictionStoreVals:(randomForestMdl;`feat1`feat2!1 2;100;100?0b;modelMetaData)
predictionStoreDict:predictionStoreKeys!predictionStoreVals

// Expected return dictionary
paramReturn:preProcParamDict,predictionStoreDict

-1"\nTesting appropriate inputs for paramConsolidate";
passingTest[.automl.paramConsolidate.node.function;(preProcParamDict;predictionStoreDict);0b;paramReturn]


