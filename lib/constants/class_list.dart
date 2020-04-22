//this is a singleton class
class ClassList {
  List<String> _list = List<String>();

  static final ClassList _instance = ClassList._internal();

  factory ClassList() {
    return _instance;
  }

  ClassList._internal();

  updateList(List<String> newList) {
    _list = newList;
  }

  List<String> getList() {
    return _list;
  }
}
