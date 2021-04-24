class ConfigContent {
  List<dynamic> _braches;
  String updateDate;
  List<String> branches;

  ConfigContent.fromJson(Map<String, dynamic> json) {
    branches = [];
    _braches = json['branches'];
    updateDate = json['update_date'];
    _braches.forEach((element) {
      branches.add(element.toString());
    });
  }
}
