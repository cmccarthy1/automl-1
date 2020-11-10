\d .automl

// Python report generation

// Python imports
canvas:.p.import`reportlab.pdfgen.canvas
table :.p.import[`reportlab.platypus]`:Table
np    :.p.import`numpy

// @kind function
// @category saveReportUtility
// @fileoverview Generate report using FPDF outlining results from current run of automl
// @param params   {dict} All data generated during the process
// @param filePath {str} Location to save report
// @return {null} Associated pdf report saved to disk
saveReport.i.FPDFReport:{[params;filePath]

  // Main variables
  bestModel:params`modelName;
  modelMeta:params`modelMetaData;
  config   :params`config;
  pdf      :canvas[`:Canvas]filePath,".pdf";
  ptype    :$[`class~config`problemType;"classification";"regression"];
  plots    :params`savedPlots;

  // Report generation
 
  // Title
  font[pdf;"Helvetica-BoldOblique";15];  
  f:title[pdf;775;0;"kdb+/q AutoML Procedure Report"];

  // Summary
  font[pdf;"Helvetica";11];
  f:cell[pdf;f;40;"This report outlines the results for a ",ptype," problem achieved through running kdb+/q AutoML."];
  f:cell[pdf;f;30;"This run started on ",string[config`startDate]," at ",string[config`startTime],"."];

  // Input data
  font[pdf;"Helvetica-Bold";13];
  f:cell[pdf;f;30;"Description of Input Data"];

  font[pdf;"Helvetica";11];
  f:cell[pdf;f;30;"The following is a breakdown of information for each of the relevant columns in the dataset:"];
  ht:saveReport.i.printDescripTab params`dataDescription;
  f:mktab[pdf;ht`t;f;ht`h;10;10];

  f:image[pdf;plots`target;f;250;280;210];
  font[pdf;"Helvetica";10];
  f:cell[pdf;f;25;"Figure 1: Distribution of input target data"];
  
  // Feature extraction and selection
  font[pdf;"Helvetica-Bold";13];
  f:cell[pdf;f;30;"Breakdown of Pre-Processing"];

  numSig:count params`sigFeats;
  font[pdf;"Helvetica";11];
  f:cell[pdf;f;30;@[string config`featExtractType;0;upper]," feature extraction and selection was performed",
    " with a total of ",string[numSig]," feature",$[1~numSig;;"s",]" produced."];
  f:cell[pdf;f;30;"Feature extraction took ",string[params`creationTime]," time in total."];

  // Cross validation
  font[pdf;"Helvetica-Bold";13];
  f:cell[pdf;f;30;"Initial Scores"];

  font[pdf;"Helvetica";11];
  xvalFunc:string config[`xv]0;
  xvalSize:config[`xv]1;
  xvalType:`$last"."vs xvalFunc;
  xval:$[xvalType in`mcsplit`pcsplit;
    "Percentage based cross validation, ",xvalFunc,", was performed with a testing set created from ",string[100*xvalSize],
      "% of the training data.";
    string[xvalSize],"-fold cross validation was performed on the training set to find the best model using ",xvalFunc,"."
    ];

  f:cell[pdf;f;30;xval];
  f:image[pdf;plots`data;f;90;500;100];
  font[pdf;"Helvetica";10];
  f:cell[pdf;f;25;"Figure 2: The data split used within this run of AutoML, with data split into training, holdout and testing sets"];

  font[pdf;"Helvetica";11];
  f:cell[pdf;f;30;"The total time taken to carry out cross validation for each model on the training set was ",
    string[modelMeta`xValTime]];
  f:cell[pdf;f;15;"where models were scored and optimized using ",string[modelMeta`metric],"."];
  f:cell[pdf;f;30;"Model scores:"];

  // Feature impact
  f:saveReport.i.printKDBTable[pdf;f;modelMeta`modelScores];
  f:image[pdf;plots`impact;f;250;280;210];
  font[pdf;"Helvetica";10];
  f:cell[pdf;f;25;"Figure 3: Feature impact of each significant feature as determined by the training set"];

  // Run models
  font[pdf;"Helvetica-Bold";13];
  f:cell[pdf;f;30;"Model selection summary"];
  font[pdf;"Helvetica";11];
  f:cell[pdf;f;30;"Best scoring model = ",string bestModel];
  f:cell[pdf;f;30;"The score on the holdout set for this model was = ",string[ modelMeta`holdoutScore],"."];
  f:cell[pdf;f;30;"The total time taken to complete the running of this model on the holdout set was: ",string[modelMeta`holdoutTime],"."];

  // Hyperparameter search
  hptyp:@[;0;upper]string srch:config`hp;
  hptyp:enlist[hptyp],$[srch=`grid;`gs;srch in`random`sobol;`rs];
  hpStr:string config hptyp 1;
  hpFunc:hpStr 0;
  hpSize:hpStr 1;
  hpMethod:`$last"."vs hpFunc;

  font[pdf;"Helvetica-Bold";13];
  f:cell[pdf;f;30;"Best Model"];

  if[not bestModel in utils.excludeList;
    font[pdf;"Helvetica";11];
    f:cell[pdf;f;30;]$[hpMethod in`mcsplit`pcsplit;
      "The hyperparameter search was completed using ",hpFunc," with a percentage of ",hpSize,"% of training data used for validation";
      "A ",hpSize,"-fold ",lower[hptyp 0]," search was performed on the training set to find the best model using, ",hpFunc,"."
      ];
    f:cell[pdf;f;30;"The following are the hyperparameters which have been deemed optimal for the model:"];
    f:saveReport.i.printKDBTable[pdf;f;params`hyperParams];
    ];
  
  // Final results
  f:cell[pdf;f;30;"The score for the best model fit on the entire training set and scored on the testing set was = ",
    string params`testScore];

  $[ptype like"*class*";
    [f:image[pdf;plots`conf;f;300;250;250];
     font[pdf;"Helvetica";10];
     cell[pdf;f;25;"Figure 4: This is the confusion matrix produced for predictions made on the testing set"]];
    [f:image[pdf;plots`reg;f;300;250;250];
     font[pdf;"Helvetica";10];
     cell[pdf;f;25;"Figure 4: Regression analysis plot produced for predictions made on the testing set"]];
    ];

  pdf[`:save][];
  }

// @kind function
// @category saveReportUtility
// @fileoverview Convert kdb description table to printable format
// @param tab {tab} kdb table to be converted
// @return {dict} Table and corresponding height
saveReport.i.printDescripTab:{[tab]
  dti:10&count tab;
  h:dti*27-dti%2;
  tab:value d:dti#tab;
  tab:.ml.df2tab .ml.tab2df[tab][`:round]3;
  t:enlist[enlist[`col],cols tab],key[d],'flip value flip tab;
  `h`t!(h;t)
  }

// @kind function
// @category saveReportUtility
// @fileoverview Convert kdb table to printable format
// @param pdf {<} PDF gen module used
// @param f   {int} The placement height from the bottom of the page 
// @param tab {tab} kdb table to be converted
// @return {int} The placement height from the bottom of the page
saveReport.i.printKDBTable:{[pdf;f;tab]
  dd:{(,'/)string(key x;count[x]#" ";count[x]#"=";count[x]#" ";value x)}tab;
  cntf:first[count dd]{[m;h;s]ff:cell[m;h 0;15;s h 1];(ff;1+h 1)}[pdf;;dd]/(f-5;0);
  first cntf
  }

// @kind function
// @category saveReportUtility
// @fileoverview Set FPDF font
// @param m   {<} pdf gen module used
// @param f   {int} font size
// @param s   {int} font size
// @return {null} Sets python font
font:{[m;f;s]
  m[`:setFont][f;s];
  }

// @kind function
// @category saveReportUtility
// @fileoverview 
// @param m   {<} pdf gen module used
// @param h   {int} the placement height from the bottom of the page 
// @param i   {int} how far below is the text
// @param txt {str} text to include
// @return {int} the placement height from the bottom of the page 
cell:{[m;h;i;txt]
  if[(h-i)<100;h:795;m[`:showPage][]];
  m[`:drawString][30;h-:i;txt];
  h
  }

// @kind function
// @category saveReportUtility
// @fileoverview 
// @param m   {<} pdf gen module used
// @param h   {int} the placement height from the bottom of the page 
// @param i   {int} how far below is the text
// @param txt {str} text to include
// @return {int} the placement height from the bottom of the page 
title:{[m;h;i;txt]
  if[(h-i)<100;h:795;m[`:showPage][]];
  m[`:drawString][150;h-:i;txt];
  h
  }

// @kind function
// @category saveReportUtility
// @fileoverview 
// @param m   {<} pdf gen module used
// @param fp  {str} filepath
// @param h   {int} the placement height from the bottom of the page 
// @param i   {int} how far below is the text
// @param wi  {int} image width
// @param hi  {int} image height
// @return {int} the placement height from the bottom of the page 
image:{[m;fp;h;i;wi;hi]
  if[(h-i)<100;h:795;m[`:showPage][]];
  m[`:drawImage][fp;40;h-:i;wi;hi];
  h
  }

// @kind function
// @category saveReportUtility
// @fileoverview 
// @param m   {<} pdf gen module used
// @param t   {<} pandas table
// @param h   {int} the placement height from the bottom of the page 
// @param i   {int} how far below is the text
// @param wi  {int} image width
// @param hi  {int} image height
// @return {int} the placement height from the bottom of the page 
mktab:{[m;t;h;i;wi;hi]
  if[(h-i)<100;h:795;m[`:showPage][]]t:table np[`:array][t][`:tolist][];
  t[`:wrapOn][m;wi;hi];
  t[`:drawOn][m;30;h-:i];
  h
  }
