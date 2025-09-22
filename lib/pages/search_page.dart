// lib/pages/search_page.dart
import 'package:flutter/material.dart';
import '../app_state.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import 'product_detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _searchResults = [];
  List<Product> _allProducts = [];
  String _selectedCategory = 'All';
  String _selectedPriceRange = 'All';
  late AnimationController _animationController;
  late Animation<double> _animation;

  final List<String> _categories = [
    'All', 'Sport', 'Dress', 'Diving', 'Chronograph', 'GMT', 'Digital', 'Casual'
  ];

  final List<String> _priceRanges = [
    'All', 
    'Under \$500', 
    '\$500 - \$1,000', 
    '\$1,000 - \$5,000', 
    '\$5,000 - \$15,000', 
    '\$15,000 - \$50,000', 
    'Over \$50,000'
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _performSearch(String query, AppState appState) {
    setState(() {
      _allProducts = appState.products.getAll();
      
      if (query.isEmpty && _selectedCategory == 'All' && _selectedPriceRange == 'All') {
        _searchResults = [];
      } else {
        _searchResults = _allProducts.where((product) {
          // Text search
          bool matchesQuery = query.isEmpty || 
              product.name.toLowerCase().contains(query.toLowerCase()) ||
              product.description.toLowerCase().contains(query.toLowerCase());
          
          // Category filter
          bool matchesCategory = _selectedCategory == 'All' || 
              product.category.toLowerCase() == _selectedCategory.toLowerCase();
          
          // Price filter
          bool matchesPrice = _selectedPriceRange == 'All' || _matchesPriceRange(product.price);
          
          return matchesQuery && matchesCategory && matchesPrice;
        }).toList();
        
        // Sort by relevance (exact name matches first)
        if (query.isNotEmpty) {
          _searchResults.sort((a, b) {
            bool aExact = a.name.toLowerCase().startsWith(query.toLowerCase());
            bool bExact = b.name.toLowerCase().startsWith(query.toLowerCase());
            if (aExact && !bExact) return -1;
            if (!aExact && bExact) return 1;
            return a.name.compareTo(b.name);
          });
        }
      }
    });
    
    if (_searchResults.isNotEmpty) {
      _animationController.forward();
    }
  }

  bool _matchesPriceRange(double price) {
    switch (_selectedPriceRange) {
      case 'Under \$500':
        return price < 500;
      case '\$500 - \$1,000':
        return price >= 500 && price < 1000;
      case '\$1,000 - \$5,000':
        return price >= 1000 && price < 5000;
      case '\$5,000 - \$15,000':
        return price >= 5000 && price < 15000;
      case '\$15,000 - \$50,000':
        return price >= 15000 && price < 50000;
      case 'Over \$50,000':
        return price >= 50000;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Watches'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search for watches, brands, or features...',
              leading: const Icon(Icons.search),
              trailing: [
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _performSearch('', appState);
                    },
                  ),
              ],
              onChanged: (query) => _performSearch(query, appState),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Category Filter
                  _buildFilterChip(
                    'Category: $_selectedCategory',
                    () => _showCategoryFilter(context, appState),
                  ),
                  const SizedBox(width: 8),
                  // Price Filter
                  _buildFilterChip(
                    'Price: $_selectedPriceRange',
                    () => _showPriceFilter(context, appState),
                  ),
                  const SizedBox(width: 8),
                  // Clear Filters
                  if (_selectedCategory != 'All' || _selectedPriceRange != 'All')
                    ActionChip(
                      label: const Text('Clear Filters'),
                      onPressed: () {
                        setState(() {
                          _selectedCategory = 'All';
                          _selectedPriceRange = 'All';
                        });
                        _performSearch(_searchController.text, appState);
                      },
                    ),
                ],
              ),
            ),
          ),
          
          // Search Results
          Expanded(
            child: _buildSearchResults(appState, isTablet),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onPressed) {
    return ActionChip(
      label: Text(label),
      onPressed: onPressed,
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
    );
  }

  Widget _buildSearchResults(AppState appState, bool isTablet) {
    if (_searchController.text.isEmpty && _selectedCategory == 'All' && _selectedPriceRange == 'All') {
      return _buildSearchSuggestions(appState);
    }
    
    if (_searchResults.isEmpty) {
      return _buildNoResults();
    }

    return FadeTransition(
      opacity: _animation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Results Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '${_searchResults.length} result${_searchResults.length == 1 ? '' : 's'} found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          
          // Results Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isTablet ? 3 : 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final product = _searchResults[index];
                return ProductCard(
                  product: product,
                  onAddToCart: () {
                    appState.addToCart(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.name} added to cart'),
                        action: SnackBarAction(
                          label: 'View Cart',
                          onPressed: () {
                            // Navigate to cart (implement based on your navigation)
                          },
                        ),
                      ),
                    );
                  },
                  onOpen: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailPage(productId: product.id),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSuggestions(AppState appState) {
    final popularProducts = appState.products.getAll().take(6).toList();
    final categories = _categories.where((c) => c != 'All').take(4).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Tips
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Search Tips',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('• Try searching by brand name (e.g., "Rolex", "Omega")'),
                  const Text('• Search by watch type (e.g., "diving", "chronograph")'),
                  const Text('• Use filters to narrow down your results'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Popular Categories
          Text(
            'Popular Categories',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories.map((category) {
              return ActionChip(
                label: Text(category),
                onPressed: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                  _performSearch(_searchController.text, appState);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          
          // Popular Products
          Text(
            'Popular Watches',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: popularProducts.length,
              itemBuilder: (context, index) {
                final product = popularProducts[index];
                return Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 12),
                  child: Card(
                    child: InkWell(
                      onTap: () {
                        _searchController.text = product.name;
                        _performSearch(product.name, appState);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.watch, size: 40),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '\${product.price.toStringAsFixed(0)}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No watches found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
              _searchController.clear();
              setState(() {
                _selectedCategory = 'All';
                _selectedPriceRange = 'All';
                _searchResults = [];
              });
            },
            child: const Text('Clear Search'),
          ),
        ],
      ),
    );
  }

  void _showCategoryFilter(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Category',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((category) {
                return ChoiceChip(
                  label: Text(category),
                  selected: _selectedCategory == category,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                    _performSearch(_searchController.text, appState);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showPriceFilter(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Price Range',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...._priceRanges.map((range) {
              return ListTile(
                title: Text(range),
                leading: Radio<String>(
                  value: range,
                  groupValue: _selectedPriceRange,
                  onChanged: (value) {
                    setState(() {
                      _selectedPriceRange = value!;
                    });
                    _performSearch(_searchController.text, appState);
                    Navigator.pop(context);
                  },
                ),
                onTap: () {
                  setState(() {
                    _selectedPriceRange = range;
                  });
                  _performSearch(_searchController.text, appState);
                  Navigator.pop(context);
                },
              );
            }).toList(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }}