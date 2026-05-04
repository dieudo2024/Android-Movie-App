import 'package:flutter/material.dart';
import 'movie.dart';
import 'api_service.dart';
import 'detail_screen.dart';
import 'add_movie_screen.dart';

class BrowseScreen extends StatefulWidget {
  @override
  _BrowseScreenState createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final ApiService apiService = ApiService();
  final ScrollController _scrollController = ScrollController();
  final List<Movie> _movies = [];
  bool _isLoading = false;
  bool _isInitialLoading = true;
  bool _hasMore = true;
  int _currentPage = 1;
  int _totalPages = 1;
  final int _pageSize = 10;
  String? _errorMessage;
  String searchQuery = "";
  String? selectedCategory;

  final List<String> categories = [
    'All',
    'Sci-Fi',
    'Action',
    'Drama',
    'Comedy',
    'Horror',
    'Mystery',
    'Thriller',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _refreshList();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMovies();
    }
  }

  void _refreshList() {
    setState(() {
      _movies.clear();
      _currentPage = 1;
      _totalPages = 1;
      _hasMore = true;
      _isInitialLoading = true;
      _errorMessage = null;
    });
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    if (_isLoading || !_hasMore) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await apiService.fetchMovies(
        search: searchQuery.isEmpty ? null : searchQuery,
        category: (selectedCategory == 'All') ? null : selectedCategory,
        page: _currentPage,
        pageSize: _pageSize,
      );

      if (!mounted) return;

      final nextPage = response.page + 1;
      final hasMore = response.totalPages > 0 && nextPage <= response.totalPages;

      setState(() {
        _movies.addAll(response.items);
        _totalPages = response.totalPages;
        _currentPage = nextPage;
        _hasMore = hasMore;
        _isLoading = false;
        _isInitialLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
        _isInitialLoading = false;
        _hasMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Movie Catalog'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search by title',
                suffixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                searchQuery = value;
                _refreshList();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: DropdownButtonFormField<String>(
              value: selectedCategory ?? 'All',
              decoration: InputDecoration(
                labelText: 'Filter by Category',
                border: OutlineInputBorder(),
              ),
              items: categories.map((String category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (newValue) {
                selectedCategory = newValue;
                _refreshList();
              },
            ),
          ),
          Expanded(
            child: _isInitialLoading
                ? Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text("Error: $_errorMessage"))
                    : _movies.isEmpty
                        ? Center(child: Text("No movies found."))
                        : ListView.builder(
                            controller: _scrollController,
                            itemCount: _movies.length + (_isLoading ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index >= _movies.length) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(child: CircularProgressIndicator()),
                                );
                              }

                              final movie = _movies[index];
                              return Card(
                                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                child: ListTile(
                                  title: Text(
                                    movie.title,
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text("${movie.category} • ${movie.year}"),
                                  trailing: Text("⭐ ${movie.rating}"),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DetailScreen(movie: movie),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddMovieScreen()),
          );

          if (result == true) {
            _refreshList();
          }
        },
        tooltip: 'Add Movie',
      ),
    );
  }
}
