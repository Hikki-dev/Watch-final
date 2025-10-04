// lib/models/brand.dart - WITH IMAGES
class Brand {
  final String id;
  final String name;
  final String logoPath;

  const Brand({required this.id, required this.name, required this.logoPath});
}

// Brand data with image paths
const brands = <Brand>[
  Brand(id: 'rolex', name: 'Rolex', logoPath: 'lib/images/brands/rolex.png'),
  Brand(id: 'omega', name: 'Omega', logoPath: 'lib/images/brands/omega.png'),
  Brand(
    id: 'patek',
    name: 'Patek Philippe',
    logoPath: 'lib/images/brands/patek.png',
  ),
  Brand(id: 'casio', name: 'Casio', logoPath: 'lib/images/brands/casio.png'),
  Brand(id: 'seiko', name: 'Seiko', logoPath: 'lib/images/brands/seiko.png'),
  Brand(
    id: 'tag_heuer',
    name: 'TAG Heuer',
    logoPath: 'lib/images/brands/tag_heuer.png',
  ),
  Brand(
    id: 'citizen',
    name: 'Citizen',
    logoPath: 'lib/images/brands/citizen.png',
  ),
];
