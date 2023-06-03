import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:godotclassreference/models/class_content.dart';

class XMLLoadBloc extends Cubit<ClassContent> {
  XMLLoadBloc() : super(ClassContent());

  void add(ClassContent state) => emit(state);
}

// abstract class XMLLoadEvent {}

// class XMLLoaded extends XMLLoadEvent {}

// class XMLLoadFinish extends XMLLoadEvent {}

// class XMLLoadBloc extends Bloc<XMLLoadEvent, ClassContent> {
//   XMLLoadBloc() : super(ClassContent()) {
//     on<XMLLoadFinish>((event, emit) {});
//   }
// }
