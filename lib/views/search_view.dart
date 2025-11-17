import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 1. Import Provider
import '../controllers/app_controller.dart';
import '../widgets/watch_card.dart';

class SearchView extends StatefulWidget {
  // 2. Remove controller from constructor
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final _searchController = TextEditingController();
  List _results = [];

  // 3. Get controller from Provider inside methods
  void _search(String query) {
    final controller = context.read<AppController>();
    setState(() {
      _results = controller.searchWatches(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    // 4. Get controller for the build method
    final controller = context.read<AppController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search watches...',
              onChanged: _search,
              leading: const Icon(Icons.search),
            ),
          ),
        ),
      ),
      body: _results.isEmpty
          ? const Center(child: Text('Search for watches'))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.7,
              ),
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final watch = _results[index];
                return WatchCard(
                  watch: watch,
                  // 5. Remove controller from WatchCard
                  onTap: () {
                    // WatchDetailView will get controller from Provider
                    Navigator.pushNamed(context, '/watch', arguments: watch.id);
                  },
                );
              },
            ),
    );
  }
}
