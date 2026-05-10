import 'package:flutter/material.dart';
import 'movie.dart';
import 'api_service.dart';

class AddMovieScreen extends StatefulWidget {
  final Movie? movieToEdit;

  AddMovieScreen({this.movieToEdit});

  @override
  _AddMovieScreenState createState() => _AddMovieScreenState();
}

class _AddMovieScreenState extends State<AddMovieScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();

  // Controllers to manage the text in each field
  late TextEditingController _titleController;
  late TextEditingController _categoryController;
  late TextEditingController _yearController;
  late TextEditingController _ratingController;
  late TextEditingController _synopsisController;
  late TextEditingController _directorController;

  @override
  void initState() {
    super.initState();
    // Pre-fill fields if we are editing; otherwise, leave them empty
    _titleController = TextEditingController(text: widget.movieToEdit?.title ?? '');
    _categoryController = TextEditingController(text: widget.movieToEdit?.category ?? '');
    _yearController = TextEditingController(text: widget.movieToEdit?.year.toString() ?? '');
    _ratingController = TextEditingController(text: widget.movieToEdit?.rating.toString() ?? '');
    _synopsisController = TextEditingController(text: widget.movieToEdit?.synopsis ?? '');
    _directorController = TextEditingController(text: widget.movieToEdit?.director ?? '');
  }

  void _saveMovie() async {
    // 1. Validation check before submission [cite: 58, 138]
    if (_formKey.currentState!.validate()) {
      final movie = Movie(
        id: widget.movieToEdit?.id ?? 0, // 0 for new, actual ID for edit
        title: _titleController.text,
        category: _categoryController.text,
        year: int.parse(_yearController.text),
        rating: double.parse(_ratingController.text),
        synopsis: _synopsisController.text,
        director: _directorController.text,
      );

      bool success;
      if (widget.movieToEdit == null) {
        success = await apiService.addMovie(movie);
      } else {
        success = await apiService.updateMovie(widget.movieToEdit!.id, movie);
      }

      if (success) {
        // Return 'true' to signal the BrowseScreen to refresh the list
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save movie. Check your API.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movieToEdit == null ? 'Add Movie' : 'Edit Movie'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Required for validation
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title *'),
                validator: (val) => val!.isEmpty ? 'Title is required' : null,
              ),
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(labelText: 'Category/Genre *'),
                validator: (val) => val!.isEmpty ? 'Category is required' : null,
              ),
              TextFormField(
                controller: _yearController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Year *'),
                validator: (val) => val!.isEmpty ? 'Year is required' : null,
              ),
              TextFormField(
                controller: _ratingController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Rating (0.0 - 10.0) *'),
                validator: (val) {
                  if (val!.isEmpty) return 'Rating is required';
                  double? r = double.tryParse(val);
                  if (r == null || r < 0 || r > 10) return 'Enter 0.0 to 10.0';
                  return null;
                },
              ),
              TextFormField(
                controller: _directorController,
                decoration: InputDecoration(labelText: 'Director'),
              ),
              TextFormField(
                controller: _synopsisController,
                maxLines: 3,
                decoration: InputDecoration(labelText: 'Synopsis'),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveMovie,
                child: Text('SAVE MOVIE'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up controllers when the widget is destroyed
    _titleController.dispose();
    _categoryController.dispose();
    _yearController.dispose();
    _ratingController.dispose();
    _synopsisController.dispose();
    _directorController.dispose();
    super.dispose();
  }
}