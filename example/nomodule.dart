import "package:clean_system/system.dart";

var init = {
  "A": (S) => [S["B"]],
  "B": (S) => [S["C"],S["D"]],
  "C": (S) => [],
  "D": (S) => [S["E"]],
};

// shoud throw NoSuchModuleError
void main(){
  var s = new System(init);
}