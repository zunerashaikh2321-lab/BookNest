class UserModel {
  final String userId;
  final String name;
  final String birthdate;
  final String gender;
  final String email;
  final String phoneNumber;
  final String profileImage;
  final String role;
  final String status;

  const UserModel({
    required this.userId,
    required this.name,
    required this.birthdate,
    required this.gender,
    required this.email,
    required this.phoneNumber,
    required this.profileImage,
    required this.role,
    required this.status,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    String s(dynamic v) => v?.toString() ?? '';
    return UserModel(
      userId: s(json['user_id']),
      name: s(json['name']),
      birthdate: s(json['birthdate']),
      gender: s(json['gender']),
      email: s(json['email']),
      phoneNumber: s(json['phone_number']),
      profileImage: s(json['profile_image']),
      role: s(json['role']),
      status: s(json['status']),
    );
  }
}
