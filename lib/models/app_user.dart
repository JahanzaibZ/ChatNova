class AppUser {
  final String id;
  final String name;
  final String? emailAddress;
  final String? phoneNumber;
  final String? profilePictureURL;
  final DateTime dateOfBirth;
  final List<String> interests;
  final bool isPro;

  AppUser({
    required this.id,
    required this.name,
    this.emailAddress,
    this.phoneNumber,
    this.profilePictureURL,
    required this.dateOfBirth,
    required this.interests,
    this.isPro = true,
  });

  AppUser copyWith(
      {String? id,
      String? name,
      String? emailAddress,
      String? phoneNumber,
      String? profilePictureURL,
      DateTime? dateOfBirth,
      List<String>? interests,
      bool? isPro}) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      emailAddress: emailAddress ?? this.emailAddress,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePictureURL: profilePictureURL ?? this.profilePictureURL,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      interests: interests ?? this.interests,
      isPro: isPro ?? this.isPro,
    );
  }
}
