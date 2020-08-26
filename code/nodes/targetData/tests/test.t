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


-1"\nTesting inappropriate target data types";

// Generate data vectors for testing of the target data ingestion function
inapprDict       :`a`b!(til 10;10?1f)
inapprTable      :([]10?1f;10?1f)
inapprArray      :{@[;0;string]x#/:prd[x]?/:(`6;0Ng;.Q.a),("xpdznuvt"$\:0)}[enlist 50]
inapprEmbedPy    :.p.import[`numpy][`:array][50?10];
procInapprDict   :`typ`data!`process,enlist inapprDict
procInapprTable  :`typ`data!`process,enlist flip inapprDict
procInapprEmbedPy:`typ`data!`process,enlist inapprEmbedPy
procInapprArray  :{x!y}[`typ`data]each `process,/:enlist each inapprArray

// Expected error message
errMsg:"Dataset not of a suitable type only 'befhijs' currently supported"

// Testing of all inappropriately typed target data
failingTest[.automl.targetData.node.function;procInapprDict ;1b;errMsg]
failingTest[.automl.targetData.node.function;procInapprTable;1b;errMsg]
failingTest[.automl.targetData.node.function;procInapprEmbedPy;1b;errMsg]
all failingTest[.automl.targetData.node.function;;1b;errMsg]each procInapprArray


-1"\nTesting appropriate target data types";

// Generate appropriate data to be loaded from process
apprData    :{x#/:prd[x]?/:(`6),("befhij"$\:0)}[enlist 50]
procApprData:{x!y}[`typ`data]each `process,/:enlist each apprData

// Testing of all supported target data values
all passingTest[.automl.targetData.node.function;;1b;]'[procApprData;apprData]

