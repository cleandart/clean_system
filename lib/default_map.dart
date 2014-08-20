part of system;

typedef V MapGenerator<K,V>(K);

class DefaultMap<K,V> implements Map{
  
  final MapGenerator<K,V> _generator;
  final Map<K,V> _data;
  
  DefaultMap(this._generator): _data = {};
  
  DefaultMap.from(Map<K,V> source, this._generator):
    this._data = new Map.from(source);
  
  V operator[](K key){
    if(!_data.containsKey(key)){
      _data[key] = _generator(key);
    }
    return _data[key];
  }
  
  operator[]=(K key, V value) => _data[key] = value;
  
  Iterable<V> get values => _data.values;
    
  Iterable<K> get keys => _data.keys;
  
  bool get isEmpty => _data.isEmpty;
  
  bool get isNotEmpty => _data.isNotEmpty;
  
  bool containsKey(K key) => _data.containsKey(key);
  
  bool containsValue(V value) => _data.containsValue(value);
  
  int get length => _data.length;
  
  void addAll(Map<K,V> other) => _data.addAll(other);
    
  V remove(Object key) => _data.remove(key);
  
  void clear() => _data.clear();
  
  void forEach(f) => _data.forEach(f);
  
  V putIfAbsent(K key, ifAbsent) => _data.putIfAbsent(key, ifAbsent);
  
  
  
  
  
}