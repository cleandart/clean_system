# Library for convenient handling of modules

## What does it provide ?

### General idea
It exposes only one class - System, but that's all you need for nice module handling.
You need only to construct the System by giving it a Map of modules, specifying how to #create / #init / #dispose
each module. Then, by just calling system.init(), the function in #init is used to initialize
each module in correct order. The correct order means, that every module is initialized only
after all modules it depends on are initialized ( vice versa for dispose ). After creating the System,
you can access the modules just as simply as in a common Map.

### More specific talking
The Map for creation of System should have the following structure: every key in Map should be 
a String, identifying the module, and the value should be a Map with keys: #create, #init, #dispose,
where #init and #dispose are optional. Under each key in this Map, there should be a function - under #create there should be a function
taking this System Map as an argument - this way you may reference to other modules in the System - and return
the constructed module. Under keys #dispose and #init, there should be function taking the constructed
module as an argument, which dispose or init the module.

If you don't specify #init or #dispose, the System will try to call .init() (or .dispose() ) on the module.
For more convenience, if you only want to specify the #create, you don't have to pass the whole Map with only the one 
entry, but just the value, which would have been under key #create.

### Example

     var config; // some config out of the system
     var someVariable;
     
     System mySystem = new System({
       'module1' : {
           #create: (s) => new ModuleFirst(config, someVariable)
           #init:  (ModuleFirst m) => m.initializeMe()
           #dispose: (ModuleFirst m) => m.disposeMe()
         },
       'module3' : (s) => new Module3(s['module2'], s['module1'], config)  // uses default .init() and .dispose()
       'module2' : {
           #create: (s) => new Module2(s['module1']),
           #init: (Module2 m) => m.init(),
           #dispose: (Module2 m) => m.dispose(), // Init and dispose are now redundant, same would be used 
         },
     });
     
     mySystem.init().then((_) {
     ... 
     // some code
     
     Module2 = mySystem['module2']; // access initialized module2
     
     ...
     }).then((_) => mySystem.dispose())
     .then((_) {
        // All modules are now disposed
     }); 

## Motivation

### Dependencies in modules can get messy
Imagine you have 30 modules, some of them are dependent on other modules,
and you have to determine the right order of initializing/disposing them... Now this
may not be a simple task sometimes - why not automatize it? System automatically
determines the correct order of initialization/dipose.

### Easy to use, nice code
Having the System, you can reference particular modules as simple as in a Map.
You can even easily use different System-s (with some changed config for example) 
in different places, and it wouldn't be much of a boilerplate code (e.g. you may
have some Maps (parts of System), for specific types of modules referencing
to each other and to some one config out of the Map, and you have some Systems with
some different configs - by adding these maps to those Systems, you may initialize
the added parts of System differently)
