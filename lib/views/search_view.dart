// lib/views/search_view.dart
import 'package:flutter/material.dart';
import '../controllers/app_controller.dart';
import '../widgets/watch_card.dart';
import 'watch_detail_view.dart';

class SearchView extends StatefulWidget {
  final AppController controller;

  const SearchView({super.key, required this.controller});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final _searchController = TextEditingController();
  List _searchResults = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search(String query) {
    setState(() {
      _searchResults = widget.controller.searchWatches(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Watches'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search watches...',
              onChanged: _search,
              leading: Icon(Icons.search),
            ),
          ),
        ),
      ),
      body: _searchResults.isEmpty && _searchController.text.isEmpty
          ? _buildSuggestions()
          : _buildResults(),
    );
  }

  Widget _buildSuggestions() {
    final brands = widget.controller.getBrands();
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Popular Brands', style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: brands.map((brand) => ActionChip(
              label: Text(brand),
              onPressed: () {
                _searchController.text = brand;
                _search(brand);
              },
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_searchResults.isEmpty) {
      return Center(child: Text('No watches found'));
    }

    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final watch = _searchResults[index];
        return WatchCard(
          watch: watch,
          controller: widget.controller,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WatchDetailView(controller: widget.controller, watchId: watch.id),
            ),
          ),
        );
      },
    );
  }
}