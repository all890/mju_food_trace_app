
class User {

  String? username;
  String? password;
  String? userType;

  User({
    this.username,
    this.password,
    this.userType
  });

  //Extract from JSON data to User object
  factory User.fromJsonToUser(Map<String, dynamic> json) => User(
    username: json["username"],
    password: json["password"],
    userType: json["userType"]
  );

  //Extract User object to JSON data
  Map<String, dynamic> fromUserToJson() {
    return <String, dynamic>{
      'username': username,
      'password': password,
      'userType': userType,
    };
  }

}