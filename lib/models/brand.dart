// lib/models/brand.dart
class Brand {
  final String id;
  final String name;
  final String logoPath;

  const Brand({required this.id, required this.name, required this.logoPath});
}

// Brand data with image paths
const brands = <Brand>[
  Brand(
    id: 'ap',
    name: 'Audemars Piguet',
    logoPath: 'assets/images/brands/ap.png',
  ),
  Brand(id: 'casio', name: 'Casio', logoPath: 'assets/images/brands/casio.png'),
  Brand(
    id: 'citizen',
    name: 'Citizen',
    logoPath: 'assets/images/brands/citizen.png',
  ),
  Brand(id: 'omega', name: 'Omega', logoPath: 'assets/images/brands/omega.png'),
  Brand(
    id: 'patek',
    name: 'Patek Philippe',
    logoPath: 'assets/images/brands/patek.png',
  ),
  Brand(
    id: 'richard_mille',
    name: 'Richard Mille',
    logoPath: 'assets/images/brands/richard_mille.png',
  ),
  Brand(id: 'rolex', name: 'Rolex', logoPath: 'assets/images/brands/rolex.png'),
  Brand(id: 'seiko', name: 'Seiko', logoPath: 'assets/images/brands/seiko.png'),
  Brand(
    id: 'swatch',
    name: 'Swatch',
    logoPath: 'assets/images/brands/swatch.png',
  ),
  Brand(
    id: 'tag_heuer',
    name: 'TAG Heuer',
    logoPath: 'assets/images/brands/tag_heuer.png',
  ),
];
