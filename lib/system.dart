library system;

import "dart:async";

part "lazy_map.dart";


class System{
  
  LazyMap<String,dynamic> parts;
  final List _init_order = [];
  
  System(Map<String,dynamic> _init_data){
    
    generator(String name){
      var res = _init_data[name](this._getParts());
      _init_order.add(res);
      return res;
    }
    
    parts = new LazyMap(generator);
    
    for(String key in _init_data.keys){
      parts[key];
    }
  }
  
  _getParts() => parts;
  
  Future<List> init() =>
      _init_order.fold(
        new Future.value(null),
        (Future soFar, service) =>
          soFar.then((_) => new Future.value(service.init()))
        
      ).then((_)=>null);

}