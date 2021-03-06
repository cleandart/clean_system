part of system;

class _ModuleWrapper {

  static Map _defaultMethods = {
    #init: (m) {
      try{
        return m.init();
      } on NoSuchMethodError catch(e) {
        return null;
      }
    },
    #dispose: (m) {
      try{
        return m.dispose();
      } on NoSuchMethodError catch(e) {
        return null;
      }
    }
  };


  factory _ModuleWrapper(dynamic param, String key) {
    if (param is Function) {
      return new _ModuleWrapper({#create: param}, key);
    } else if (param is Map) {
      var methods = {};
      for (var m in [#create, #init, #dispose]) {
        methods[m] = param.containsKey(m) ? param[m] : _defaultMethods[m];
      }
      return new _ModuleWrapper._withMethods(methods, key);
    } else {
      throw new ArgumentError("Module can only be created from Map or Function");
    }
  }

  final key;
  _ModuleWrapper._withMethods(this._methods, this.key);

  Map _methods;
  var _m;

  create(s) {
    _m = _methods[#create](s);
    return _m;
  }

  init() {
    return _methods[#init](_m);
  }

  dispose() {
    return _methods[#dispose](_m);
  }

  getInnerModule() => _m;

}
