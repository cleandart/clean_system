import "dart:async";
import "package:clean_system/system.dart";

class Cls {

  final data;
  final name;

  Cls(this.name, this.data) {
    print("default create $this");
  }

  init() {
    print("default init $this");
    return new Future.value(null);
  }

  dispose() {
    print("default dispose $this");
    return new Future.value(null);
  }

  String toString() => "$name<$data>";

}

createF(name, [data]) {
  var m = new Cls(name, data);
  print("custom create $m");
  return m;
}

initF(m) {
  print("custom init $m");
  return new Future.value(null);
}

disposeF(m) {
  print("custom dispose $m");
  return new Future.value(null);
}

var init = {
  "A": (s) => new Cls("A", s["B"]),
  "B": {#create: (s) => createF("B", s["D"]), #init: initF, #dispose: disposeF},
  "C": (s) => new Cls("C", s["D"]),
  "D": (s) => new Cls("D", ""),
  "pure": (s) => "pure"
};

void main(){
  var s = new System(init);
  s.init().then((_) => print(s.graphDOT()));
}
