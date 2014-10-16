part of system;

class _ModuleWrapper {

  factory _ModuleWrapper(dynamic param) {
    if (param is Function) {
      return new _ModuleWrapper.fromFunction(param);
    } else if (param is Map) {
      return new _ModuleWrapper.fromMap(param);
    } else {
      throw new ArgumentError("Module can only be created from Map or Function");
    }
  }

  _ModuleWrapper.fromFunction(dynamic f(s)) {
    var m;

    _create = (s) {
      m = f(s);
      return m;
    };

    _init = () {
      try{
        return m.init();
      } on NoSuchMethodError catch(e) {
        return null;
      }
    };

    _dispose = () {
      try{
        return m.dispose();
      } on NoSuchMethodError catch(e) {
        return null;
      }
      finally {
        m = null;
      }
    };
  }

  _ModuleWrapper.fromMap(Map map) {
    var m;

    _create = (s) {
      m = map[#create](s);
      return m;
    };

    _init = () {
      return map[#init](m);
    };

    _dispose = () {
      var result = map[#dispose](m);
      m = null;
      return result;
    };
  }

  Function _create;

  dynamic create(s) {
    return _create(s);
  }

  Function _init;

  dynamic init() {
    return _init();
  }

  Function _dispose;

  dynamic dispose() {
    return _dispose();
  }

}
