// lib/views/search_view.dart - SIMPLIFIED
import 'package:flutter/material.dart';
import '../controllers/app_controller.dart';
import '../widgets/watch_card.dart';

class SearchView extends StatefulWidget {
  final AppController controller;
  const SearchView({super.key, required this.controller});
  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final _searchController = TextEditingController();
  List _results = [];

  void _search(String query) {
    setState(() {
      _results = widget.controller.searchWatches(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
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
      body: _results.isEmpty
          ? Center(child: Text('Search for watches'))
          : GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                  controller: widget.controller,
                  onTap: () {
                    Navigator.pushNamed(context, '/watch', arguments: watch.id);
                  },
                );
              },
            ),
    );
  }
}

