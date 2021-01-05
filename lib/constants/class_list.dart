//this is a singleton class
import 'package:godotclassreference/models/class_content.dart';

class ClassList {
  List<ClassContent> _list = List<ClassContent>();

  static final ClassList _instance = ClassList._internal();

  factory ClassList() {
    return _instance;
  }

  ClassList._internal();

  updateList(List<ClassContent> newList) {
    _list = newList;
  }

  List<ClassContent> getList() {
    return _list;
  }
}
