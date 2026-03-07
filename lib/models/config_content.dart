class ConfigContent {
  String? updateDate;
  Map<String, List<String>> branchTranslations = {};

  ConfigContent();

  ConfigContent.fromJson(Map<String, dynamic> json) {
    updateDate = json['update_date'];

    (json['translation'] as List<dynamic>).forEach((bt) {
      List<String> translations = [];
      (bt["translation"] as List).forEach((e) {
        if (e.runtimeType == String) {
          translations.add(e);
        }
      });
      branchTranslations[bt['branch']] = translations;
    });
  }

  Map<String, dynamic> toJson() {
    final _branchTranslations = branchTranslations.keys
        .map((k) => {'branch': k, 'translation': branchTranslations[k]});
    return {
      'update_date': updateDate,
      'translation': [..._branchTranslations],
    };
  }
}
