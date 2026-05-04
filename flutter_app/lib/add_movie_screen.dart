import 'package:flutter/material.dart';
import 'movie.dart';
import 'api_service.dart';

class AddMovieScreen extends StatefulWidget {
  @override
  _AddMovieScreenState createState() => _AddMovieScreenState();
}

class _AddMovieScreenState extends State<AddMovieScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();

  // Form fields[cite: 8]
  String title = '';
  String category = 'Sci-Fi';
  String director = '';
  int year = 2024;
  double rating = 0.0;
  String description = '';
  String synopsis = '';

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      Movie newMovie = Movie(
        id: 0, // Backend handles ID generation[cite: 8]
        title: title,
        category: category,
        director: director,
        year: year,
        rating: rating,
        description: description,
        synopsis: synopsis,
        createdAt: DateTime.now(),
      );

      bool success = await apiService.addMovie(newMovie);
      if (success) {
        Navigator.pop(context, true); // Return to list and trigger refresh
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to add movie")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add New Movie")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) => value!.isEmpty ? 'Enter a title' : null,
                onSaved: (value) => title = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Director'),
                validator: (value) => value!.isEmpty ? 'Enter a director' : null,
                onSaved: (value) => director = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Year'),
                keyboardType: TextInputType.number,
                onSaved: (value) => year = int.parse(value!),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Synopsis'),
                maxLines: 3,
                onSaved: (value) => synopsis = value!,
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: _submitForm, child: Text("Save Movie")),
            ],
          ),
        ),
      ),
    );
  }
}