part of system;

typedef V MapGenerator<K,V>(K);

class LazyMap<K,V> {
  
  final MapGenerator<K,V> _generator;
  final Map<K,V> _data;
  
  LazyMap(this._generator): _data = {};
  
  V operator[](K key){
    if(!_data.containsKey(key)){
      _data[key] = _generator(key);
    }
    return _data[key];
  }
  
}