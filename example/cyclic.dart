import "package:clean_system/system.dart";

var init = {
  "A": (S) => [S["B"]],
  "B": (S) => [S["C"],S["D"]],
  "C": (S) => [],
  "D": (S) => [S["A"]],
};

// shoud throw CyclicDependenciesError
void main(){
  var s = new System(init);
  s.init();
}