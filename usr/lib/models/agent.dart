class Agent {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? mobile;
  final String userName;
  final String role;
  final bool isActive;
  final String? password; // Only for creation logic, usually not returned by API

  Agent({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.mobile,
    required this.userName,
    required this.role,
    required this.isActive,
    this.password,
  });

  factory Agent.fromJson(Map<String, dynamic> json) {
    return Agent(
      id: json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'],
      userName: json['userName'] ?? '',
      role: json['role'] ?? 'Agent',
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'mobile': mobile,
      'userName': userName,
      'role': role,
      'isActive': isActive,
      if (password != null) 'password': password,
    };
  }

  Agent copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? mobile,
    String? userName,
    String? role,
    bool? isActive,
    String? password,
  }) {
    return Agent(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      userName: userName ?? this.userName,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      password: password ?? this.password,
    );
  }
}
