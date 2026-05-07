import 'package:flutter/material.dart';
import 'movie.dart';
import 'api_service.dart';
import 'detail_screen.dart';
import 'add_movie_screen.dart';

class BrowseScreen extends StatefulWidget {
  final String? initialCategory;
  final String? initialSearch;

  const BrowseScreen({
    super.key,
    this.initialCategory,
    this.initialSearch,
  });

  @override
  _BrowseScreenState createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final ApiService apiService = ApiService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  
  final List<Movie> _movies = [];
  bool _isLoading = false;
  bool _isInitialLoading = true;
  bool _hasMore = true;
  int _currentPage = 1;
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

    selectedCategory = widget.initialCategory ?? 'All';
    searchQuery = widget.initialSearch ?? '';
    _searchController.text = searchQuery;
    if (selectedCategory != null &&
        selectedCategory != 'All' &&
        !categories.contains(selectedCategory)) {
      categories.insert(1, selectedCategory!);
    }

    _scrollController.addListener(_onScroll);
    _refreshList();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Detect when user is near bottom of list to trigger pagination
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMovies();
    }
  }

  void _refreshList() {
    if (!mounted) return;
    setState(() {
      _movies.clear();
      _currentPage = 1;
      _hasMore = true;
      _isInitialLoading = true;
      _errorMessage = null;
    });
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    // Prevent duplicate calls or loading if we reached the end
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await apiService.fetchMovies(
        search: searchQuery.isEmpty ? null : searchQuery,
        category: (selectedCategory == 'All' || selectedCategory == null) ? null : selectedCategory,
        page: _currentPage,
        pageSize: _pageSize,
      );

      if (!mounted) return;

      setState(() {
        _movies.addAll(response.items);
        
        // Update pagination logic
        // If current page is less than total pages, there's more to load
        _hasMore = _currentPage < response.totalPages;
        
        if (_hasMore) {
          _currentPage++;
        }
        
        _isLoading = false;
        _isInitialLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "Error connecting to server. Make sure your FastAPI is running.";
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
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard),
            tooltip: 'Dashboard',
            onPressed: () {
              Navigator.pushNamed(context, '/dashboard');
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.red),
            tooltip: 'Favorites',
            onPressed: () {
              Navigator.pushNamed(context, '/favorites');
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshList,
          )
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by title',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                searchQuery = value;
                // Add a small delay or check for length if needed, 
                // but _refreshList works for immediate feedback.
                _refreshList();
              },
            ),
          ),
          
          // Category Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: DropdownButtonFormField<String>(
              initialValue: selectedCategory ?? 'All',
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
                setState(() {
                  selectedCategory = newValue;
                });
                _refreshList();
              },
            ),
          ),
          
          // List View Area
          Expanded(
            child: _isInitialLoading
                ? Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(_errorMessage!, textAlign: TextAlign.center, style: TextStyle(color: Colors.red)),
                      ))
                    : _movies.isEmpty
                        ? Center(child: Text("No movies found."))
                        : ListView.builder(
                            controller: _scrollController,
                            itemCount: _movies.length + (_hasMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index >= _movies.length) {
                                return Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              final movie = _movies[index];
                              return Card(
                                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                elevation: 2,
                                child: ListTile(
                                  title: Text(
                                    movie.title,
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text("${movie.category} • ${movie.year}"),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.star, color: Colors.amber, size: 20),
                                      Text("${movie.rating}"),
                                    ],
                                  ),
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
