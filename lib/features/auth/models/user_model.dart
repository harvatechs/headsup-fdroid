class AppUser {
  final String uid;
  final String? email;
  final String displayName;
  final bool isAnonymous;
  final DateTime createdAt;

  const AppUser({
    required this.uid,
    this.email,
    required this.displayName,
    required this.isAnonymous,
    required this.createdAt,
  });

  factory AppUser.fromMap(Map<String, dynamic> map, String id) {
    return AppUser(
      uid: id,
      email: map['email'] as String?,
      displayName: map['displayName'] as String? ?? (map['isAnonymous'] == true ? 'Guest User' : 'User'),
      isAnonymous: map['isAnonymous'] as bool? ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'isAnonymous': isAnonymous,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    bool? isAnonymous,
    DateTime? createdAt,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
