import 'package:godotclassreference/bloc/tap_event_bloc.dart';

export 'tap_event_bloc.dart';
export 'tap_event_arg.dart';

class AllBlocs {
  TapEventBloc tapEventBloc = TapEventBloc();

  static final AllBlocs _singleton = AllBlocs._internal();

  factory AllBlocs() {
    return _singleton;
  }

  AllBlocs._internal();
  // late them
}

final AllBlocs blocs = AllBlocs();
