library system;

import "dart:async";
import "dart:collection";

part "module_wrapper.dart";
part "default_map.dart";


/**
 * Error thrown when there are cyclic dependencies
 */
class CyclicDependenciesError extends Error {
  final Iterable<String> path;

  CyclicDependenciesError(this.path);

  String toString() => "Dependency cycle: ${path.join("->")}";
}

/**
 * Error thrown if the requested module was not defined in System
 */
class NoSuchModuleError extends Error {
  final Iterable<String> path;

  NoSuchModuleError(this.path);

  String toString() =>
      "No such module: '${path.last}' that is required by ${path.join("->")}";
}


/**
 * This class meant for convenient module handling. System is initialized with
 * a Map, where keys are identifiers of modules and values are Maps with following keys: #create, #init, #dispose.
 * Entry under #create should be a function, which takes the System Map as an argument.
 * Therefore, the module can be constructed using other modules in the System Map by simply
 * referencing to them. Values under keys #init and #dispose should be functions taking
 * the constructed module as an argument, and specifying how to init or dispose them.
 *
 * If the value under some key in System Map is not a Map, it is handled as value for #create,
 * and default #init and #dispose, calling .init() or .dispose() respectively, are added.
 *
 * Upon constructing the System, it creates all the given modules and determines the
 * right order for initializing them. System ensures, that every module is initialized
 * only after all modules it depends on are initialized. As for dispose, every module
 * is disposed only after all modules it depends on are disposed.
 *
 * Init / dispose of System initializes/disposes all modules.
 * Once the System is created, all modules can be referenced by key as from a common Map.
 */
class System {

  _DefaultMap<String, dynamic> _modules;

  final List<_ModuleWrapper> _initOrder = [];

  final Set _path = new LinkedHashSet();

  Map<String, _ModuleWrapper> _moduleWrappers;

  final _DefaultMap<String, List<String>> _graph = new _DefaultMap((_)=>[]);

  /**
   * Constructs the System from a Map [initData] of String identifiers of modules as keys and Map
   * specifying how to create/init/dispose the module as a value.
   * [initData] should contain the entries as specified in the documentation of System class.
   * Constructs all given modules.
   */
  System(Map<String, dynamic> initData) {
    _moduleWrappers = new Map.fromIterable(initData.keys, value: (key) => new _ModuleWrapper(initData[key], key));
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
     var res = module.create(_modules);
    _initOrder.add(module);
    return res;
  }

  /// Initialize all modules in the right order
  Future init() =>
    Future.forEach(_initOrder, (m) => new Future.sync((){
      return m.init();
    }));

  /// Dispose all modules in the right order (reversed to initialization)
  Future dispose() =>
    Future.forEach(_initOrder.reversed, (m) => new Future.sync((){
      return m.dispose();
    }));

  /// Get module under given key
  operator[](val) =>
    (_moduleWrappers.containsKey(val))?
        _moduleWrappers[val].getInnerModule()
      :
        throw new NoSuchModuleError([val]);

  /// Draw an oriented graph of dependencies
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