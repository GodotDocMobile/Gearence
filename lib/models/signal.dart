class SignalArgument {
  String index;
  String name;
  String type;

  SignalArgument({this.index, this.name, this.type});
}

class Signal {
  String name;
  String description;

  List<SignalArgument> arguments;

  Signal({this.name, this.description, this.arguments});
}
