\l automl.q
.automl.loadfile`:init.q

// The following utilities are used to test that a function is returning the expected
// error message or data, these functions will likely be provided in some form within
// the test.q script provided as standard for the testing of q and embedPy code

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

\S 42

// Generate input data to be passed to saveGraph

// Name of best model
modelName:`randomForestRegressor

// Generate a path to save images to
savePath:.automl.utils.ssrwin .automl.path,"/outputs/testing/images"
system"mkdir",$[.z.o like "w*";" ";" -p "],savePath;
pathDict:enlist[`images]!enlist savePath

// Generate confusion matrix
preds:10?0b
yTest:10?0b
confMatrix:.ml.confmat[preds;yTest]

// Generate impact dictionary
colNames  :`col1`col2`col3
impactVals:asc 3?100f
impactDict:colNames:colNames!impactVals

analyzeModel:`confMatrix`impact!(confMatrix;impactDict)

// Generate config dictionaries
configClass0:`problemType`saveopt!(`class;0)
configClass1:`problemType`saveopt!(`class;1)
configClass2:`problemType`saveopt!(`class;2)
configReg2  :`problemType`saveopt!(`reg  ;2)

paramDictKeys:`modelName`pathDict`analyzeModel
paramDictVals:(modelName;pathDict;analyzeModel)
paramDict    :paramDictKeys!paramDictVals

paramDictConfig0   :paramDict,enlist[`config]!enlist configClass0
paramDictConfig1   :paramDict,enlist[`config]!enlist configClass1
paramDictConfig2   :paramDict,enlist[`config]!enlist configClass2
paramDictConfigReg2:paramDict,enlist[`config]!enlist configReg2

-1"\nTesting appropriate inputs for saveGraph";

passingTest[.automl.saveGraph.node.function;paramDictConfig0   ;1b;(::)]
passingTest[.automl.saveGraph.node.function;paramDictConfig1   ;1b;(::)]
passingTest[.automl.saveGraph.node.function;paramDictConfig2   ;1b;(::)]
passingTest[.automl.saveGraph.node.function;paramDictConfigReg2;1b;(::)]

