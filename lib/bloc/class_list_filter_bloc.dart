import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:godotclassreference/isar/schema/class_content.dart';


class FilterOption {
  final classNodeType type;
  final bool value;

  FilterOption(this.type, this.value);
}

class ClassListFilterBloc extends Cubit<FilterOption> {
  ClassListFilterBloc() : super(FilterOption(classNodeType.None, true));

  void add(FilterOption filterOption) => emit(filterOption);
}
