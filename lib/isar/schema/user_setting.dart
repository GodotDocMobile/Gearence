import 'package:isar_plus/isar_plus.dart';

part 'user_setting.g.dart';

@collection
class UserSetting {
  final int id;

  @Index(unique: true)
  String? key;

  String? stringValue;
  int? intValue;
  bool? boolValue;

  UserSetting({required this.id});

  @ignore
  // Helper to get the value regardless of type
  dynamic get value => stringValue ?? intValue ?? boolValue;
}
