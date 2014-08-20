import "dart:async";
import "package:clean_system/system.dart";

class Cls {
  
  final data;
  final name;
  
  Cls(this.name, this.data){
    print("Construction $this");
  }
  
  init(){
    print("Initialization $this");
    new Future.value(47);
  }
  
  String toString() => "$name<$data>";
}

var init = {
  "A": (S) => new Cls("A",S["B"]),
  "B": (S) => new Cls("B",S["D"]),
  "C": (S) => new Cls("C",S["D"]),
  "D": (S) => new Cls("D",""),
  "pure": (S) => "pure",
};

void main(){
  var s = new System(init);
  s.init();
}