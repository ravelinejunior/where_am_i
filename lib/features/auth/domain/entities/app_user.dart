import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final bool isAdmin;

  const AppUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.isAdmin = false,
  });

  String get initials {
    if (displayName != null && displayName!.isNotEmpty) {
      final parts = displayName!.trim().split(' ');
      if (parts.length >= 2) {
        return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
      }
      return displayName![0].toUpperCase();
    }
    if (email != null && email!.isNotEmpty) return email![0].toUpperCase();
    return '?';
  }

  @override
  List<Object?> get props => [uid, email, displayName, photoUrl, isAdmin];
}
