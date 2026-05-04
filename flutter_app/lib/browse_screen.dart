import 'package:flutter/material.dart';
import 'movie.dart';
import 'api_service.dart';
import 'detail_screen.dart';
import 'add_movie_screen.dart'; // Ensure this file exists in your project

class BrowseScreen extends StatefulWidget {
  @override
  _BrowseScreenState createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Movie>> futureMovies;
  String searchQuery = "";
  String? selectedCategory;

  // List of categories for the filter
  final List<String> categories = ['All', 'Sci-Fi', 'Action', 'Drama', 'Comedy', 'Horror'];

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  void _refreshList() {
    setState(() {
      // Pass null if 'All' is selected to fetch all movies from the API
      futureMovies = apiService.fetchMovies(
        search: searchQuery.isEmpty ? null : searchQuery,
        category: (selectedCategory == 'All') ? null : selectedCategory,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Movie Catalog'),
      ),
      body: Column(
        children: [
          // 1. Search Bar Requirement
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

          // 2. Category Filter Requirement
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
                setState(() {
                  selectedCategory = newValue;
                  _refreshList();
                });
              },
            ),
          ),

          // 3. Browse List Requirement (Item Cards)
          Expanded(
            child: FutureBuilder<List<Movie>>(
              future: futureMovies,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No movies found."));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final movie = snapshot.data![index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        title: Text(movie.title, style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("${movie.category} • ${movie.year}"),
                        trailing: Text("⭐ ${movie.rating}"),
                        // 4. Navigation to Detail Screen Requirement
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
                );
              },
            ),
          ),
        ],
      ),
      
      // 5. Navigation to Add Item Form Requirement
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          // Navigating to the add screen and waiting for a result
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddMovieScreen()),
          );
          
          // Refresh the list if a new movie was successfully POSTed
          if (result == true) {
            _refreshList();
          }
        },
      ),
    );
  }
}