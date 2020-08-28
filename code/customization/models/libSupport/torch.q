\d .automl

// The purpose of this file is to include all the necessary utilities to create a minimal
// interface for the support of PyTorch models. It also acts as a location to which users defined
// PyTorch models could be added

// import pytorch as torch
torch:.p.import[`torch];

// list all defined PyTorch models defined by the user, here `null as none are to be used by default
models.torchlist:`null;
models.nnlist:models.keraslist,models.torchlist
