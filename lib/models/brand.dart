class Brand {
  final String id; // slug-like: 'rolex'
  final String name; // 'Rolex'
  final String logoAsset; // 'assets/images/brands/rolex.png'

  const Brand({required this.id, required this.name, required this.logoAsset});
}

const brands = <Brand>[
  Brand(
    id: 'patek',
    name: 'Patek Philippe',
    logoAsset: 'assets/images/brands/patek.png',
  ),
  Brand(
    id: 'swatch',
    name: 'Swatch',
    logoAsset: 'assets/images/brands/swatch.png',
  ),
  Brand(
    id: 'richard_mille',
    name: 'Richard Mille',
    logoAsset: 'assets/images/brands/richard_mille.png',
  ),
  Brand(
    id: 'rolex',
    name: 'Rolex',
    logoAsset: 'assets/images/brands/rolex.png',
  ),
  Brand(
    id: 'casio',
    name: 'Casio',
    logoAsset: 'assets/images/brands/casio.png',
  ),
  Brand(
    id: 'ap',
    name: 'Audemars Piguet',
    logoAsset: 'assets/images/brands/ap.png',
  ),
  Brand(
    id: 'tag_heuer',
    name: 'TAG Heuer',
    logoAsset: 'assets/images/brands/tag_heuer.png',
  ),
  Brand(
    id: 'omega',
    name: 'Omega',
    logoAsset: 'assets/images/brands/omega.png',
  ),
  Brand(
    id: 'citizen',
    name: 'Citizen',
    logoAsset: 'assets/images/brands/citizen.png',
  ),
  Brand(
    id: 'seiko',
    name: 'Seiko',
    logoAsset: 'assets/images/brands/seiko.png',
  ),
];
