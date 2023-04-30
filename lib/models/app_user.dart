class AppUser {
  final String? id;
  final String? name;
  final String? emailAddress;
  final String? phoneNumber;
  final String? profilePictureURL;
  final DateTime? dateOfBirth;
  final bool? isPro;

  AppUser({
    this.id,
    this.name,
    this.emailAddress,
    this.phoneNumber,
    this.profilePictureURL,
    this.dateOfBirth,
    this.isPro,
  });

  AppUser copyWith(
      {String? id,
      String? name,
      String? emailAddress,
      String? phoneNumber,
      String? profilePictureURL,
      DateTime? dateOfBirth,
      bool? isPro}) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      emailAddress: emailAddress ?? this.emailAddress,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePictureURL: profilePictureURL ?? this.profilePictureURL,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      isPro: isPro ?? this.isPro,
    );
  }
}
