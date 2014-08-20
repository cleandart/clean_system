library system;

import "dart:async";

part "default_map.dart";

class CyclicDependenciesError extends Error{
  final Set cycle;
  
  CyclicDependenciesError(this.cycle);
  
  String toString() => "Dependency cycle: $cycle";
}

class NoSuchTaskError extends Error{
  final String task;
  
  NoSuchTaskError(this.task);
  
  String toString() => "No such task: $task";
}

class System{
  
  DefaultMap<String,dynamic> tasks;
  final List _init_order = [];
  
  System(Map<String,dynamic> _init_data){
    _init(_init_data);
  }
  
  
  _init(data){
    Set active = new Set();
        
    generator(String name){
      
      if(active.contains(name))
        throw new CyclicDependenciesError(active);
        
      active.add(name);
      
      if(!data.containsKey(name))
        throw new NoSuchTaskError(name);
      
      var res = data[name](this._actualTasks());
      _init_order.add(res);
      
      active.remove(name);
      
      return res;
    }
    
    tasks = new DefaultMap(generator);
    
    for(String key in data.keys){
      tasks[key];
    }
  }
  
  
  _actualTasks() => tasks;
  
  
  Future<List> init() =>
      _init_order.fold(
        new Future.value(null),
        (Future soFar, service) =>
          soFar.then((_){
            try{
              service.init;
            } catch(e) {
              return new Future.value(null);
            }
            return new Future.value(service.init());
          })   
      ).then((_)=>null);

}