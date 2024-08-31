import 'dart:convert';

class Users {
  int? id;
  String? fullname;
  String? email;
  String? password;

  Users({this.id, this.fullname, this.email, this.password});

  factory Users.fromJson(Map<String, dynamic> json) => Users(
        id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
        fullname: json['fullname'],
        email: json['email'],
        password: json['password'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullname': fullname,
        'email': email,
        'password': password,
      };
}


List<Users> usersFromJson(String str) {
  final jsonData = json.decode(str);
  return List<Users>.from(jsonData.map((x) => Users.fromJson(x)));
}


String usersToJson(List<Users> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
