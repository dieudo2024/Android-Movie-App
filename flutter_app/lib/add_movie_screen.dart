import 'package:flutter/material.dart';
import 'movie.dart';
import 'api_service.dart';

class AddMovieScreen extends StatefulWidget {
  final Movie? movieToEdit;

  const AddMovieScreen({super.key, this.movieToEdit});

  @override
  _AddMovieScreenState createState() => _AddMovieScreenState();
}

class _AddMovieScreenState extends State<AddMovieScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();

  late TextEditingController _titleController;
  late TextEditingController _categoryController;
  late TextEditingController _yearController;
  late TextEditingController _ratingController;
  late TextEditingController _synopsisController;
  late TextEditingController _directorController;

  @override
  void initState() {
    super.initState();
    // Removed extra null-checks on non-nullable year/rating
    _titleController = TextEditingController(text: widget.movieToEdit?.title ?? '');
    _categoryController = TextEditingController(text: widget.movieToEdit?.category ?? '');
    _yearController = TextEditingController(text: widget.movieToEdit?.year.toString() ?? '');
    _ratingController = TextEditingController(text: widget.movieToEdit?.rating.toString() ?? '');
    _synopsisController = TextEditingController(text: widget.movieToEdit?.synopsis ?? '');
    _directorController = TextEditingController(text: widget.movieToEdit?.director ?? '');
  }

  void _saveMovie() async {
    if (_formKey.currentState!.validate()) {
      // Create the movie object according to your movie.dart model
      final movie = Movie(
        id: widget.movieToEdit?.id, // Passes null if adding, actual ID if editing
        title: _titleController.text,
        category: _categoryController.text,
        director: _directorController.text,
        year: int.parse(_yearController.text),
        rating: double.parse(_ratingController.text),
        synopsis: _synopsisController.text,
        createdAt: widget.movieToEdit?.createdAt ?? DateTime.now(),
      );

      bool success;
      if (widget.movieToEdit == null) {
        success = await apiService.addMovie(movie);
      } else {
        // Ensure your api_service has the updateMovie method
        success = await apiService.updateMovie(widget.movieToEdit!.id!, movie);
      }

      if (success) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to save movie. Check your API.")),
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
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title *'),
                validator: (val) => val!.isEmpty ? 'Title is required' : null,
              ),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category/Genre *'),
                validator: (val) => val!.isEmpty ? 'Category is required' : null,
              ),
              TextFormField(
                controller: _yearController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Year *'),
                validator: (val) => val!.isEmpty ? 'Year is required' : null,
              ),
              TextFormField(
                controller: _ratingController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Rating (0.0 - 10.0) *'),
                validator: (val) {
                  if (val!.isEmpty) return 'Rating is required';
                  double? r = double.tryParse(val);
                  if (r == null || r < 0 || r > 10) return 'Enter 0.0 to 10.0';
                  return null;
                },
              ),
              TextFormField(
                controller: _directorController,
                decoration: const InputDecoration(labelText: 'Director *'),
                validator: (val) => val!.isEmpty ? 'Director is required' : null,
              ),
              TextFormField(
                controller: _synopsisController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Synopsis *'),
                validator: (val) => val!.isEmpty ? 'Synopsis is required' : null,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveMovie,
                child: const Text('SAVE MOVIE'),
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