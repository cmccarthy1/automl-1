// Apply the user defined train test split functionality onto the users feature/target datasets returning
// the train-test split data as a list of (xtrain;ytrain;xtest;ytest)
\d .automl

// @kind function
// @category node
// @fileoverview Split data into training and testing sets
// @param cfg      {dict}          Location and method by which to retrieve the data
// @param feat     {tab}           The feature data as a table 
// @param tgt      {(num[];sym[])} Numerical or symbol vector containing the target dataset
// @param sigFeats {sym[]}         Significant features
// @return         {dict}          Data separated into training and testing sets
trainTestSplit.node.function:{[cfg;feats;tgt;sigFeats]
  tts:trainTestSplit.applyTTS[cfg;feats;tgt;sigFeats];
  trainTestSplit.ttsReturnType tts
  }

// Input information
trainTestSplit.node.inputs  :`config`features`target`sigFeats!"!+FS"

// Output information
trainTestSplit.node.outputs :"!"