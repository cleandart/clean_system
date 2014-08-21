part of system;

typedef V _MapGenerator<K,V>(K);

class _DefaultMap<K,V> {
  
  final _MapGenerator<K,V> _generator;
  final Map<K,V> _data;
  
  _DefaultMap(this._generator): _data = {};
  
  V operator[](K key) {
    return _data.putIfAbsent(key, () => _generator(key));
  }
    
  Iterable<K> get keys => _data.keys; 
}

class _CallbackDefaultMap<K,V> extends _DefaultMap<K,V>{
  
  final _callback;
  
  _CallbackDefaultMap(_generator, this._callback): super(_generator);
 
  V operator[](K key) {
    _callback(key);
    return super[key];
  }
}