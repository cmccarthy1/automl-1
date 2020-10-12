\l automl.q
.automl.loadfile`:init.q

// The following utilities are used to test that a function is returning the expected
// error message or data, these functions will likely be provided in some form within
// the test.q script provided as standard for the testing of q and embedPy code

// @kind function
// @category tests
// @fileoverview Ensure that a test that is expected to fail, 
//   does so with an appropriate message
// @param function {(func;proj)} The function or projection to be tested
// @param data {any} The data to be applied to the function as an individual item for
//   unary functions or a list of variables for multivariant functions
// @param applyType {boolean} Is the function to be applied unary(1b) or multivariant(0b)
// @param expectedError {string} The expected error message on failure of the function
// @return {boolean} Function errored with appropriate message (1b), function failed
//   inappropriately or passed (0b)
failingTest:{[function;data;applyType;expectedError]
  // Is function to be applied unary or multivariant
  applyType:$[applyType;@;.];
  failureFunction:{[err;ret](`TestFailing;ret;err~ret)}[expectedError;];
  functionReturn:applyType[function;data;failureFunction];
  $[`TestFailing~first functionReturn;last functionReturn;0b]
  }

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
  
// Initialize datasets

\S 42

// Datasets
n:100
freshData    :([]n?til 10;n?1f;n?1f;n?1f)
nlpData      :([](n;2)#200?.Q.a;n?n;n?1f)
nlpMultiData :([](n;2)#200?.Q.a;(n;2)#200?.Q.a;n?n;n?1f)
normData     :([]n?100;n?1f;n?10;n?10f)
normBulkData :.automl.featureCreation.normal.bulktransform normData
normTruncData:.automl.featureCreation.normal.truncSingleDecomp normData

// Configuration Dictionaries
cfgKey:`featExtractType`funcs
freshCfg    :(cfgKey,`aggcols)!`fresh`.ml.fresh.params`x
nlpCfg      :(cfgKey,`w2v`seed)!`nlp`.automl.featureCreation.normal.default,0,1234
normCfg     :cfgKey!`normal`.automl.featureCreation.normal.default
normBulkCfg :cfgKey!`normal`.automl.featureCreation.normal.bulktransform
normTruncCfg:cfgKey!`normal`.automl.featureCreation.normal.truncSingleDecomp
inappropCfg :cfgKey!`newFeatType`.automl.extractNewFeats

// Utilities

featCreate:{[cfg;feat;returnType]
  feats:.automl.featureCreation.node.function[cfg;feat];
  $[returnType~`key;
      asc key feats;
    returnType~`count;
      count feats`features;
      ]
  }

// Tests

// Expected Returns
returnCols :`creationTime`featModel`features
featTypeErr:"Feature extraction type is not currently supported"

-1"Testing FRESH feature creation";
passingTest[featCreate;(freshCfg;freshData;`key  );0b;returnCols]
passingTest[featCreate;(freshCfg;freshData;`count);0b;10        ]

-1"Testing NLP feature creation";
passingTest[featCreate;(nlpCfg;nlpData     ;`key  );0b;returnCols]
passingTest[featCreate;(nlpCfg;nlpData     ;`count);0b;100       ]
passingTest[featCreate;(nlpCfg;nlpMultiData;`key  );0b;returnCols]
passingTest[featCreate;(nlpCfg;nlpMultiData;`count);0b;100       ]

-1"Testing normal feature creation";
passingTest[featCreate;(normCfg     ;normData     ;`key  );0b;returnCols]
passingTest[featCreate;(normCfg     ;normData     ;`count);0b;104       ]
passingTest[featCreate;(normBulkCfg ;normBulkData ;`key  );0b;returnCols]
passingTest[featCreate;(normBulkCfg ;normBulkData ;`count);0b;104       ]
passingTest[featCreate;(normTruncCfg;normTruncData;`key  );0b;returnCols]
passingTest[featCreate;(normTruncCfg;normTruncData;`count);0b;104       ]

-1"Testing failing cases";
failingTest[featCreate;(inappropCfg;freshData;());0b;featTypeErr]
