
class User {
  Data? data;
  Support? support;

  User({this.data, this.support});

  User.fromJson(Map<String, dynamic> json) {
    if(json["data"] is Map)
      this.data = json["data"] == null ? null : Data.fromJson(json["data"]);
    if(json["support"] is Map)
      this.support = json["support"] == null ? null : Support.fromJson(json["support"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if(this.data != null)
      data["data"] = this.data?.toJson();
    if(this.support != null)
      data["support"] = this.support?.toJson();
    return data;
  }
}

class Support {
  String? url;
  String? text;

  Support({this.url, this.text});

  Support.fromJson(Map<String, dynamic> json) {
    if(json["url"] is String)
      this.url = json["url"];
    if(json["text"] is String)
      this.text = json["text"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["url"] = this.url;
    data["text"] = this.text;
    return data;
  }
}

class Data {
  int? id;
  String? email;
  String? firstName;
  String? lastName;
  String? avatar;

  Data({this.id, this.email, this.firstName, this.lastName, this.avatar});

  Data.fromJson(Map<String, dynamic> json) {
    if(json["id"] is int)
      this.id = json["id"];
    if(json["email"] is String)
      this.email = json["email"];
    if(json["first_name"] is String)
      this.firstName = json["first_name"];
    if(json["last_name"] is String)
      this.lastName = json["last_name"];
    if(json["avatar"] is String)
      this.avatar = json["avatar"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["id"] = this.id;
    data["email"] = this.email;
    data["first_name"] = this.firstName;
    data["last_name"] = this.lastName;
    data["avatar"] = this.avatar;
    return data;
  }
}