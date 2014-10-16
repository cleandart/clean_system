part of system;

abstract class _ModuleWrapper {

  static wrap(dynamic param) {
    if (param is Function) {
      return new _ModuleFunctionWrapper(param);
    } else if (param is Map) {
      return new _ModuleMapWrapper(param);
    } else {
      throw new ArgumentError("Module can only be created from Map or Function");
    }
  }

  dynamic create(s);

  dynamic init();

  dynamic dispose();

}

class _ModuleFunctionWrapper extends _ModuleWrapper {

  var _m;
  dynamic _create;

  _ModuleFunctionWrapper(this._create(s));

  dynamic create(s) {
    _m = _create(s);
    return _m;
  }

  dynamic init() {
    try{
      return _m.init();
    } on NoSuchMethodError catch(e) {
      return null;
    }
  }

  dynamic dispose() {
    try{
      return _m.dispose();
    } on NoSuchMethodError catch(e) {
      return null;
    }
    finally {
      _m = null;
    }
  }

}

class _ModuleMapWrapper extends _ModuleFunctionWrapper {
  Map _map;

  _ModuleMapWrapper(Map map): super(map[#create]) {
    _map = map;
  }

  @override
  dynamic init() {
    if (_map.containsKey(#init)) {
      return _map[#init](super._m);
    } else {
      return super.init();
    }
  }

  @override
  dynamic dispose() {
    if (_map.containsKey(#dispose)) {
      return _map[#dispose](super._m);
    } else {
      return super.dispose();
    }
  }

}

