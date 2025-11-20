// lib/models/user.dart
class User {
  final String id;
  final String name;
  final String email;
  final String? profileImagePath; // For Firebase Storage URL
  final Set<String> favorites; // Read-only, set via AppController

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImagePath, 
    Set<String>? favorites, 
  }) : favorites = favorites ?? {}; // Initialize or use passed-in set.

  bool isFavorite(String watchId) => favorites.contains(watchId);
}
