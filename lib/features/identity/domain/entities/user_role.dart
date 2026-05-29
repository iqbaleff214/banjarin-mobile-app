enum UserRole {
  user,
  admin;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (r) => r.name == value,
      orElse: () => UserRole.user,
    );
  }
}
