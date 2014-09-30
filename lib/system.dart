library system;

import "dart:async";
import "dart:collection";

part "default_map.dart";

class CyclicDependenciesError extends Error {
  final Iterable<String> path;

  CyclicDependenciesError(this.path);

  String toString() => "Dependency cycle: ${path.join("->")}";
}

class NoSuchModuleError extends Error {
  final Iterable<String> path;

  NoSuchModuleError(this.path);

  String toString() =>
      "No such module: '${path.last}' that is required by ${path.join("->")}";
}

class System {

  _DefaultMap<String, dynamic> _modules;

  final List _initOrder = [];

  final Set _path = new LinkedHashSet();

  final Map<String, Function> _initData;

  final _DefaultMap<String, List<String>> _graph = new _DefaultMap((_)=>[]);

  System(this._initData) {
    _modules =
        new _CallbackDefaultMap(_pathUpdater(_createModule), _graphUpdater);
    for (var k in _initData.keys) _modules[k];
  }

  _graphUpdater(name){
    if(_path.isNotEmpty){
      _graph[_path.last].add(name);
    }
  }

  _pathUpdater(fn(String name)) {
    return (String name) {

      if(!_initData.containsKey(name))
        throw new NoSuchModuleError(new List.from(_path)..add(name));

      if(_path.contains(name))
        throw new CyclicDependenciesError(new List.from(_path)..add(name));

      _path.add(name);
      var res = fn(name);
      _path.remove(name);

      return res;
    };
  }

  _createModule(String name) {

    var res = _initData[name](_modules);

    _initOrder.add(res);

    return res;
  }

  Future init() =>
    Future.forEach(_initOrder, (m) => new Future.sync((){
      try{
        return m.init();
      } on NoSuchMethodError catch(e){
        return null;
      }
    }));

  Future dispose() =>
    Future.forEach(_initOrder.reversed, (m) => new Future.sync((){
      try{
        return m.dispose();
      } on NoSuchMethodError catch(e){
        return null;
      }
    }));

  String graphDOT(){

    List lines = [];
    lines.add("digraph dependencies {");
    lines.add("  rankdir=LR;");

    for (String module in _initData.keys)
      lines.add("  $module;");

    for (String from in _graph.keys)
      for (String to in _graph[from])
        lines.add(" $to -> $from ;");

    lines.add("}");
    lines.add("");
    return lines.join("\n");
  }
}