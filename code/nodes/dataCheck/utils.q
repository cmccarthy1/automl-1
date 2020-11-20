\d .automl

// Error presentation

// @kind function
// @category dataCheckUtility
// @fileoverview print to standard out flagging the removal of inappropriate columns
// @param clist {sym[]} list of all columns in the dataset
// @param slist {sym[]} sublist of columns appropriate for the use case
// @param cfg   {dict} configuration information assigned by the user and related to the current run
// @return      {(Null;stdout)} generic null if all columns suitable, appropriate print out
//   in the case there are outstanding issues
dataCheck.i.errColumns:{[clist;slist;cfg]
  if[count[clist]<>count slist;
    -1 "\n Removed the following columns due to type restrictions for ",string cfg;
    0N!clist where not clist in slist
    ]
  }

// Parameter retrieval functionality

// @kind function
// @category dataCheckUtility
// @fileoverview retrieve a parameter flatfile from disk 
// @param  fileName {char[]} name of the file from which the dictionary is being extracted
// @return          {dict} configuration dictionary retrieved from a flatfile
dataCheck.i.getDict:{[fileName]
  d:dataCheck.i.paramParse[fileName;"/models/flat_parameters/"];
  idx:(k except`scf;
    k except`xv`gs`scf`seed;
    $[`xv in k;`xv;()],$[`gs in k;`gs;()];
    $[`scf in k;`scf;()];
    $[`seed in k:key d;`seed;()]);
  fnc:(key;
    {get string first x};
    {(x 0;get string x 1)};
    {key[x]!`$value x};
    {$[`rand_val~first x;first x;get string first x]});
  // Addition of empty dictionary entry needed as parsing
  // of file behaves oddly if only a single entry is given to the system
  if[sgl:1=count d;d:(enlist[`]!enlist""),d];
  d:{$[0<count y;@[x;y;z];x]}/[d;idx;fnc];
  if[sgl;d:1_d];
  d
  }

// @kind function
// @category dataCheckUtility
// @fileoverview retrieve default parameters and update with custom information
// @param cfg  {dict} Configuration information assigned by the user and related to the current run
// @param feat {tab}  The feature data as a table
// @param ptyp {sym}  problem type being solved (`nlp/`normal/`fresh)
// @return     {dict} configuration dictionary modified with any custom information
dataCheck.i.getCustomConfig:{[feat;cfg;ptyp]
  d:$[ptyp=`fresh ;dataCheck.i.freshDefault[];
      ptyp=`normal;dataCheck.i.normalDefault[];
      ptyp=`nlp   ;dataCheck.i.nlpDefault[];
      '`$"Inappropriate type supplied"
    ];
  d:$[(typ:type cfg)in 10 -11 99h;
      [if[10h~typ ;cfg:dataCheck.i.getDict cfg];
       if[-11h~typ;cfg:dataCheck.i.getDict$[":"~first cfg;1_;]cfg:string cfg];
       $[min key[cfg]in key d;d,cfg;'`$"Inappropriate key provided for configuration input"]
      ];
      not any cfg;d;
      '`$"cfg must be passed the identity `(::)`, a filepath to a parameter flatfile",
         " or a dictionary with appropriate key/value pairs"
    ];
  if[ptyp=`fresh;
     d[`aggcols]:$[100h~typagg:type d`aggcols;d[`aggcols]feat;
                   11h~abs typagg;d`aggcols;
                   '`$"aggcols must be passed function or list of columns"
                 ]
  ];
  d,enlist[`tf]!enlist 1~checkimport[0]
  }

// @kind function
// @category dataCheckUtility
// @fileoverview default parameters used in the application of 'FRESH' AutoML
// @return {dict} default dictionary which will be used if no user updates are supplied
dataCheck.i.freshDefault:{`aggcols`funcs`xv`gs`rs`hp`trials`prf`scf`seed`saveopt`hld`tts`sz`sigFeats`saveModelName!
  ({first cols x};`.ml.fresh.params;(`.ml.xv.kfshuff;5);(`.automl.gs.kfshuff;5);
  (`.automl.rs.kfshuff;5);`grid;256;`.automl.utils.fitPredict;`class`reg!(`.ml.accuracy;`.ml.mse);`rand_val;2;
   0.2;`.automl.utils.ttsNonShuff;0.2;`.automl.featureSignificance.significance;`)
  }

// @kind function
// @category dataCheckUtility
// @fileoverview default parameters used in the application of 'normal' AutoML 
// @return {dict} default dictionary which will be used if no user updates are supplied
dataCheck.i.normalDefault:{`xv`gs`rs`hp`trials`funcs`prf`scf`seed`saveopt`hld`tts`sz`sigFeats`saveModelName!
  ((`.ml.xv.kfshuff;5);(`.automl.gs.kfshuff;5);(`.automl.rs.kfshuff;5);`grid;256;`.automl.featureCreation.normal.default;
   `.automl.utils.fitPredict; `class`reg!(`.ml.accuracy;`.ml.mse);
   `rand_val;2;0.2;`.ml.traintestsplit;0.2;`.automl.featureSignificance.significance;`)
  }

// @kind function
// @category dataCheckUtility
// @fileoverview default parameters used in the application of 'NLP' AutoML
// @return {dict} default dictionary which will be used if no user updates are supplied
dataCheck.i.nlpDefault:{`xv`gs`rs`hp`trials`funcs`prf`scf`seed`saveopt`hld`tts`sz`sigFeats`w2v`saveModelName!
  ((`.ml.xv.kfshuff;5);(`.automl.gs.kfshuff;5);(`.automl.rs.kfshuff;5);`grid;256;`.automl.featureCreation.normal.default;
   `.automl.utils.fitPredict;`class`reg!(`.ml.accuracy;`.ml.mse);
   `rand_val;2;0.2;`.ml.traintestsplit;0.2;`.automl.featureSignificance.significance;0;`)
  }

// @kind function
// @category dataCheckUtility
// @fileoverview parse the hyperparameter flat file
// @param fileName {char[]} name of the file to be parsed
// @param filePath {char[]} file path to the hyperparmeter file relative to `.automl.path`
// @returns  > dictionary mapping model name to possible hyper parameters 
dataCheck.i.paramParse:{[fileName;filePath]
  key[k]!(value@){(!).("S=;")0:x}each k:(!).("S*";"|")0:hsym`$.automl.path,filePath,fileName
  }

// Save path generation functionality

// @kind function
// @category dataCheckUtility
// @fileoverview create the folders that are required for the saving of the config,
//   models, images and reports
// @param cfg {dict} Configuration information assigned by the user and related to the current run
// @return the file paths relevant for saving reports/config etc to file, both as full path format 
//   and truncated for use in outputs to terminal
dataCheck.i.pathConstruct:{[cfg]
  names:`config`models;
  if[cfg[`saveopt]=2;names:names,`images`report];
  pname:$[`~cfg`saveModelName;dataCheck.i.dateTimePath;dataCheck.i.customPath]cfg;
  paths:pname,/:string[names],\:"/";
  dictNames:`$string[names],\:"SavePath";
  dictNames!paths
  }

// @kind function
// @category dataCheckUtility
// @fileoverview Construct save path using date and time of the run
// @param cfg {dict} Configuration information assigned by the user and related to the current run
// @return {str} Path constructed based on run date and time 
dataCheck.i.dateTimePath:{[cfg]
  date:string cfg`startDate;
  time:string cfg`startTime;
  path,"/",ssr["outputs/",date,"/run_",time,"/";":";"."]
  }

// @kind function
// @category dataCheckUtility
// @fileoverview Construct save path using custom model name
// @param cfg {dict} Configuration information assigned by the user and related to the current run
// @return {str} Path constructed based on user defined custom model name
dataCheck.i.customPath:{[cfg]
  modelName:cfg[`saveModelName];
  modelName:$[10h=type modelName;modelName;
   -11h=type modelName;string modelName;
   '"unsupported input type, model name must be a symbol atom or string"];
  filePath:path,"/outputs/namedModels/",modelName,"/";
  if[count key hsym`$filePath;
    '"This save path already exists, please choose another model name"];
  filePath
  }

