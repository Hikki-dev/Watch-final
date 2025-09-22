// lib/models/user.dart
class User {
  final String id;
  final String name;
  final String email;
  final Set<String> _favorites = {};

  User({
    required this.id,
    required this.name,
    required this.email,
  });

  Set<String> get favorites => Set.unmodifiable(_favorites);

  bool isFavorite(String watchId) => _favorites.contains(watchId);

  void addFavorite(String watchId) => _favorites.add(watchId);

  void removeFavorite(String watchId) => _favorites.remove(watchId);

  void toggleFavorite(String watchId) {
    if (isFavorite(watchId)) {
      removeFavorite(watchId);
    } else {
      addFavorite(watchId);
    }
  }
}
