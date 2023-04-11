import 'package:godotclassreference/models/method.dart';
import 'package:godotclassreference/models/method_argument.dart';

class Annotation {
  String? name = '';
  List<MethodArgument>? params = [];
  String? description = '';
  MethodReturn? annotationReturn;

  Annotation({this.name, this.params, this.description, this.annotationReturn});
}
