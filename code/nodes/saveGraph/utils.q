\d .automl

// Utility functions for saveGraph

// Python functionality
plt:.p.import`matplotlib.pyplot;


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
  ax[`:set_title][`label pykw ""];
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
