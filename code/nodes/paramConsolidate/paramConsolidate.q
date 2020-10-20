\d .automl

// Join together all information collected during preprocessing, processing and configuration creation
// in order to provide all information required for the generation of report/meta/graph/model saving

// @kind function
// @category node
// @fileoverview Consolidate all information together that was generated during the process
// @param preProcParams   {dict} Data generated during the preprocess stage
// @param predictionStore {dict} Data generated during the prediction stage
// @return {dict} All data collected along the entire process joined
paramConsolidate.node.function:{[preProcParams;predictionStore]
  preProcParams,predictionStore
  }

// Input information
paramConsolidate.node.inputs  :`preprocParams`predictionStore!"!!"

// Output information
paramConsolidate.node.outputs :"!"
