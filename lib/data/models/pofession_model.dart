class ProfessionModel {
  int? id;
  String? name;

  ProfessionModel({this.id, this.name});

  ProfessionModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
  static List<ProfessionModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => ProfessionModel.fromJson(json)).toList();
  }
}