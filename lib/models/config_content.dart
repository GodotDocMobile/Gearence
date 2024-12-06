class ConfigContent {
  List<dynamic>? _braches;
  String? updateDate;
  List<String> branches = [];
  Map<String, List<String>> branchTranslations = {};

  ConfigContent.fromJson(Map<String, dynamic> json) {
    _braches = json['branches'];
    updateDate = json['update_date'];
    _braches!.forEach((element) {
      branches.add(element["branch"].toString());
      List<String> translations = [];
      (element["translation"] as List).forEach((e) {
        if (e.runtimeType == String) {
          translations.add(e);
        }
      });
      // branchTranslations.add({element["branch"]: translations});
      branchTranslations[element["branch"]] = translations;
    });
  }
}
