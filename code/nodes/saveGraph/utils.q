\d .automl

// Utility functions for saveGraph

// Python functionality
plt:.p.import`matplotlib.pyplot;

// @kind function
// @category saveGraphUtility
// @fileoverview Create regression target distribution plot and save down locally
// @param target    {float[]} All target values
// @param savePath  {int} Path to where plots are to be saved
// @return {null} Target distribution plot saved to appropriate location
saveGraph.i.regTargetPlot:{[target;savePath]
  plt[`:hist][target;`bins pykw 10;`ec pykw"black"];
  plt[`:title]["Target Distribution";`fontsize pykw 12];
  plt[`:xlabel]["Target"];
  plt[`:ylabel]["Count"];
  filePath:savePath,"Target_Distribution.png";
  plt[`:savefig][filePath;`bbox_inches pykw"tight"];
  plt[`:close][];
  }

// @kind function
// @category saveGraphUtility
// @fileoverview Create binary target distribution plot and save down locally
// @param target    {float[]} All target values
// @param savePath  {int} Path to where plots are to be saved
// @return {null} Target distribution plot saved to appropriate location
saveGraph.i.classTargetPlot:{[target;savePath]
  classes:asc target;
  classDict:count each group classes;
  plt[`:bar][string key classDict;value classDict];
  plt[`:title]["Target Classes Binned"];
  plt[`:xlabel]["Target Classes"];
  plt[`:ylabel]["Count"];
  filePath:savePath,"Target_Distribution.png";
  plt[`:savefig][filePath;`bbox_inches pykw"tight"];
  plt[`:close][];
  }


// @kind function
// @category saveGraphUtility
// @fileoverview Save confusion matrix
// @param confMatrix {int[]} Confusion matrix
// @param classes    {str} Classes of possible predictions
// @param modelName  {str} Name of best model
// @param savePath   {str} Path to where images are to be saved
// @return {null} Saves confusion matrix to appropriate location
saveGraph.i.displayConfMatrix:{[confMatrix;classes;modelName;savePath]
  colorMap:plt`:cm.Blues;
  subPlots:plt[`:subplots][`figsize pykw 5 5];
  fig:subPlots[`:__getitem__][0];
  ax:subPlots[`:__getitem__][1];
  ax[`:imshow][confMatrix;`interpolation pykw`nearest;`cmap pykw colorMap];
  ax[`:set_title][`label pykw "Confusion Matrix"];
  tickMarks:til count classes;
  ax[`:xaxis.set_ticks]tickMarks;
  ax[`:set_xticklabels]classes;
  ax[`:yaxis.set_ticks]tickMarks;
  ax[`:set_yticklabels]classes;
  thresh:max[raze confMatrix]%2;
  shape:.ml.shape confMatrix;
  saveGraph.i.addText[confMatrix;thresh;;]. 'cross[til shape 0;til shape 1];
  plt[`:xlabel]["Predicted Label";`fontsize pykw 12];
  plt[`:ylabel]["Actual label";`fontsize pykw 12];
  filePath:savePath,sv["_";string(`Confusion_Matrix;modelName)],".png";
  plt[`:savefig][filePath;`bbox_inches pykw"tight"];
  plt[`:close][];
  } 


// @kind function
// @category saveGraphUtility
// @fileoverview Add text to confusion matrix
// @param confMatrix {int[]} Confusion matrix
// @param thresh     {int} Threshold value
// @param i          {int} Row in the confusion matrix
// @param j          {int} column in the confusion matrix
// @return {null} Adds text to plot
saveGraph.i.addText:{[confMatrix;thresh;i;j]
  color:$[thresh<confMatrix[i;j];`white;`black];
  valueStr:string confMatrix[i;j];
  plt[`:text][j;i;valueStr;`horizontalalignment pykw`center;`color pykw color]
  }


// @kind function
// @category saveGraphUtility
// @fileoverview Create impact plot and save down locally
// @param impact    {float[]} The impact value of each feature
// @param modelName {modelName} Name of best model
// @param savePath  {int} Path to where plots are to be saved
// @return {null} Impact plot saved to appropriate location
saveGraph.i.plotImpact:{[impact;modelName;savePath]
  plt[`:figure][`figsize pykw 20 20];
  subPlots:plt[`:subplots][];
  fig:subPlots[@;0];
  ax:subPlots[@;1];
  num:20&count value impact;
  nCount:til num;
  valImpact:num#value impact;
  keyImpact:num#key impact;
  ax[`:barh][nCount;valImpact;`align pykw`center];
  ax[`:set_yticks]nCount;
  ax[`:set_yticklabels]keyImpact;
  ax[`:set_title]"Feature Impact: ",string modelName;
  ax[`:set_ylabel]"Columns";
  ax[`:set_xlabel]"Relative feature impact";
  filePath:savePath,sv["_";string(`Impact_Plot;modelName)],".png";
  plt[`:savefig][filePath;`bbox_inches pykw"tight"];
  plt[`:close][];
  }


// @kind function
// @category saveGraphUtility
// @fileoverview Create residual plot and save down locally
// @param residDict {dict} The resid and true values
// @param modelName {modelName} Name of best model
// @param savePath  {int} Path to where plots are to be saved
// @return {null} Residual plot saved to appropriate location
saveGraph.i.plotResiduals:{[residDict;modelName;savePath]
  resid:residDict[`resids];
  true :residDict[`true];
  plt[`:figure][`figsize pykw 10 10];
  marker:$[1000>count true;"o";"."];
  plt[`:scatter][true;resid;`marker pykw marker];
  xVals:.ml.arange[min true;max true;1];
  plt[`:plot][xVals;count[xVals]#0;"--"];
  plt[`:title]["Residual plot for ",string modelName];
  plt[`:xlabel]["True Values";`fontsize pykw 12];
  plt[`:ylabel]["Residuals";`fontsize pykw 12];
  filePath:savePath,sv["_";string(`Residual_Plot;modelName)],".png";
  plt[`:savefig][filePath;`bbox_inches pykw"tight"];
  plt[`:close][];  
  }
