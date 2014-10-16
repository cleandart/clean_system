library system;

import "dart:async";
import "dart:collection";

part "module_wrapper.dart";
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

  final List<_ModuleWrapper> _initOrder = [];

  final Set _path = new LinkedHashSet();

  Map<String, _ModuleWrapper> _moduleWrappers;

  final _DefaultMap<String, List<String>> _graph = new _DefaultMap((_)=>[]);

  System(Map<String, dynamic> initData) {
    _moduleWrappers = new Map.fromIterable(initData.keys, value: (key) => _ModuleWrapper.wrap(initData[key]));
    _modules =
        new _CallbackDefaultMap(_pathUpdater(_createModule), _graphUpdater);
    for (var k in _moduleWrappers.keys) _modules[k];
  }

  _graphUpdater(name){
    if(_path.isNotEmpty){
      _graph[_path.last].add(name);
    }
  }

  _pathUpdater(fn(String name)) {
    return (String name) {

      if(!_moduleWrappers.containsKey(name))
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
    _ModuleWrapper module = _moduleWrappers[name];
    _initOrder.add(module);

    return module.create(_modules);
  }

  Future init() =>
    Future.forEach(_initOrder, (m) => new Future.sync((){
      return m.init();
    }));

  Future dispose() =>
    Future.forEach(_initOrder.reversed, (m) => new Future.sync((){
      return m.dispose();
    }));

  String graphDOT(){

    List lines = [];
    lines.add("digraph dependencies {");
    lines.add("  rankdir=LR;");

    for (String module in _moduleWrappers.keys)
      lines.add("  $module;");

    for (String from in _graph.keys)
      for (String to in _graph[from])
        lines.add(" $to -> $from ;");

    lines.add("}");
    lines.add("");
    return lines.join("\n");
  }
}