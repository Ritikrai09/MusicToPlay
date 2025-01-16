
class Language {
  String? name;
  int? id;
  String? language;
  String? pos;

  Language({this.name, this.id,this.language,this.pos});

  Language.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    language = json['code'];
    id = json['id'];
    pos = json['position'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['position'] = pos;
    data['code'] = language;
    return data;
  }

  List<Object> get props => [id.toString(),name.toString(), language.toString()];
  bool get stringify => false;
}
