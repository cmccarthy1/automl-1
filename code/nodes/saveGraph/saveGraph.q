\d .automl

// Save all the graphs relevant for the generation of reports and for prosperity

// @kind function
// @category node
// @fileoverview Save all graphs needed for reports 
// @param params {dict} All data generated during the preprocessing and
//  prediction stages
// @return {null} All graphs needed for reports are saved to appropriate location
saveGraph.node.function:{[params]
  savePath:params[`pathDict;`images];
  saveGraph.targetPlot[params;savePath];
  saveGraph.confusionMatrix[params;savePath];
  saveGraph.impactPlot[params;savePath];
  saveGraph.residualPlot[params;savePath];
  params
  }

// Input information
saveGraph.node.inputs  :"!"

// Output information
saveGraph.node.outputs :"!"
