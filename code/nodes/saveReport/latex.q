\d .automl

// For simplicity of implementation this code is written largely in python
// this is necessary as a result of the excessive use of structures such as with clauses
// which are more difficult to handle via embedPy

// @kind function
// @category saveReport
// @fileoverview Load in python latex function
// @return {<} Python latex function
saveReport.reportGen:.p.get`python_latex

// @kind function
// @category saveReport
// @fileoverview Generate automl report in latex report if available
// @params   {dict} All data generated during the process
// @filePath {str} Location to save the report
// @return {null} Latex report is saved down locally 
saveReport.latexGenerate:{[params;filePath]
  dataDescribe:params`dataDescription;
  hyperParams :params`hyperParams;
  scoreDict   :params[`modelMetaData]`modelScores;
  describeTab :saveReport.descriptionTab dataDescribe;
  scoreTab    :saveReport.scoringTab scoreDict;
  gridTab     :saveReport.gridSearch hyperParams;
  pathDict:params[`savedPlots],`fpath`path!(filePath;.automl.path);
  params:string each params;
  saveReport.reportGen[params;pathDict;describeTab;scoreTab;gridTab;utils.excludeList];
  }

// @kind function
// @category saveReport
// @fileoverview Convert table to a pandas dataframe
// @param tab {tab} To be converted to a pandas dataframe
// @return {<} Pandas dataframe object  
tab2dfFunc:{[tab]
  .ml.tab2df[tab][`:round][3]
  }

// @kind function
// @category saveReport
// @fileoverview Convert table to a pandas dataframe
// @param describe {dict} Description of input data
// @return {<} Pandas dataframe object 
saveReport.descriptionTab:{[describe]
  describeDict:enlist[`column]!enlist key describe;
  describeTab:flip[describeDict],'value describe;
  tab2dfFunc describeTab
  }
  
// @kind function
// @category saveReport
// @fileoverview Convert table to a pandas dataframe
// @param scoreDict {dict} Scores of each model
// @return {<} Pandas dataframe object 
saveReport.scoringTab:{[scoreDict]
  scoreTab:flip `model`score!(key scoreDict;value scoreDict);
  tab2dfFunc scoreTab
  }

// @kind function
// @category saveReport
// @fileoverview Convert table to a pandas dataframe
// @param hyperParam {dict} Hyperparameters used on the best model
// @return {<} Pandas dataframe object 
saveReport.gridSearch:{[hyperParams]
  if[99h=type hyperParams;
    grid:flip`param`val!(key hyperParams;value hyperParams);
    hyperParams:tab2dfFunc grid
    ];
  hyperParams
  }
