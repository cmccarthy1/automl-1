\d .automl

// Save all the graphs relevant for the generation of reports and for prosperity

// @kind function
// @category node
// @fileoverview Save all graphs needed for reports 
// @param params {dict} All data generated during the preprocessing and
//  prediction stages
// @return {dict} ??
saveGraph.node.function:{[params]
  savePath:params[`pathDict;`images];
  saveGraph.confusionMatrix[params;savePath];
  saveGraph.impactPlot[params;savePath];
  }

// Input information
saveGraph.node.inputs  :"!"

// Output information
saveGraph.node.outputs :"!"
