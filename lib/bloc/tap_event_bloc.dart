import 'package:flutter_bloc/flutter_bloc.dart';

import 'tap_event_arg.dart';

class TapEventBloc extends Cubit<TapEventArg> {
  TapEventBloc() : super(TapEventArg(className: '', fieldName: ''));

  void add(TapEventArg tapEventArg) => emit(tapEventArg);

  void reached() => emit(TapEventArg(className: '', fieldName: ''));
}
