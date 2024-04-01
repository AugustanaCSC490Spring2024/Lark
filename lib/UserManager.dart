class UserManager {
  static final UserManager _instance = UserManager._internal();

  factory UserManager() {
    return _instance;
  }

  UserManager._internal();

  String? _username;

  String? get username => _username;

  void setUsername(String name) {
    _username = name;
  }
}