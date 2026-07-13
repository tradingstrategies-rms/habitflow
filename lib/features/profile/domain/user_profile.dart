import 'family_role.dart';

/// [UserProfile] represents the detailed user profile stored in Firestore.
class UserProfile {
  const UserProfile({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.displayName,
    this.birthday,
    required this.country,
    required this.language,
    required this.timezone,
    required this.familyRole,
    this.photoUrl,
  });

  final String uid;
  final String firstName;
  final String lastName;
  final String displayName;
  final DateTime? birthday;
  final String country;
  final String language;
  final String timezone;
  final FamilyRole familyRole;
  final String? photoUrl;

  /// Creates a [UserProfile] from a JSON map.
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] as String,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      birthday: json['birthday'] != null 
          ? DateTime.parse(json['birthday'] as String) 
          : null,
      country: json['country'] as String? ?? 'US',
      language: json['language'] as String? ?? 'en',
      timezone: json['timezone'] as String? ?? 'UTC',
      familyRole: FamilyRole.fromString(json['familyRole'] as String?),
      photoUrl: json['photoUrl'] as String?,
    );
  }

  /// Converts the [UserProfile] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'displayName': displayName,
      'birthday': birthday?.toIso8601String(),
      'country': country,
      'language': language,
      'timezone': timezone,
      'familyRole': familyRole.name,
      'photoUrl': photoUrl,
    };
  }

  /// Creates a copy of this [UserProfile] with the given fields replaced.
  UserProfile copyWith({
    String? firstName,
    String? lastName,
    String? displayName,
    DateTime? birthday,
    String? country,
    String? language,
    String? timezone,
    FamilyRole? familyRole,
    String? photoUrl,
  }) {
    return UserProfile(
      uid: uid,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      displayName: displayName ?? this.displayName,
      birthday: birthday ?? this.birthday,
      country: country ?? this.country,
      language: language ?? this.language,
      timezone: timezone ?? this.timezone,
      familyRole: familyRole ?? this.familyRole,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
