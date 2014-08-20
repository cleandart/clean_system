part of system;

typedef V MapGenerator<K,V>(K);

class DefaultMap<K,V> {
  
  final MapGenerator<K,V> _generator;
  final Map<K,V> _data;
  
  DefaultMap(this._generator): _data = {};
  
  DefaultMap.from(Map<K,V> source, this._generator):
    this._data = new Map.from(source);
  
  V operator[](K key) {
    return _data.putIfAbsent(key, () => _generator(key));
  }
    
  Iterable<V> get values => _data.values;
    
  Iterable<K> get keys => _data.keys;
  
  bool get isEmpty => _data.isEmpty;
  
  bool get isNotEmpty => _data.isNotEmpty;
  
  bool containsKey(K key) => _data.containsKey(key);
  
  bool containsValue(V value) => _data.containsValue(value);
  
  int get length => _data.length;
  
  void forEach(f) => _data.forEach(f);  
  
}

class CallbackDefaultMap<K,V> extends DefaultMap<K,V>{
  
  final _callback;
  
  CallbackDefaultMap(_generator, this._callback): super(_generator);
 
  V operator[](K key) {
    _callback(key);
    return super[key];
  }
}