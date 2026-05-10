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
  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();
  final _directorController = TextEditingController();
  final _yearController = TextEditingController();
  final _ratingController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _synopsisController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      final movie = Movie(
        id: widget.movieToEdit?.id, // Passes null if adding, actual ID if editing
        title: _titleController.text,
        category: _categoryController.text,
        director: _directorController.text,
        year: int.parse(_yearController.text),
        rating: double.parse(_ratingController.text),
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
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
    } catch (e) {
      setState(() {
        _errorMessage = "Error when adding movie. Please try again.";
      });
    } finally {
      setState(() {
        _isSubmitting = false;
      });
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
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (v) => v!.isEmpty ? 'Category is required' : null,
              ),
              TextFormField(
                controller: _directorController,
                decoration: InputDecoration(labelText: 'Director'),
                validator: (value) => value!.isEmpty ? 'Enter a director' : null,
                // onSaved: (value) => director = value!,
              ),
              TextFormField(
                controller: _yearController,
                decoration: InputDecoration(labelText: 'Year'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Year is required';
                  final year = int.tryParse(v);
                  if (year == null || year < 1800 || year > DateTime.now().year + 1) return 'Invalid year';
                  return null;
                },
              ),
              TextFormField(
                controller: _ratingController,
                decoration: const InputDecoration(labelText: 'Rating (0.0 - 10.0) *'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Rating is required';
                  final double? rating = double.tryParse(v);
                  if (rating == null || rating < 0 || rating > 10) return 'Invalid rating';
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
              TextFormField(
                controller: const _descriptionController,
                decoration: InputDecoration(labelText: 'Description (optional)'),
              ),
              const SizedBox(height: 30),
              if (_errorMessage != null)
                Text(_errorMessage!, style: TextStyle(color: Colors.red)),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting ? CircularProgressIndicator() : Text('Add Movie'),
              ),
              SizedBox(height: 20),
              // ElevatedButton(onPressed: _submitForm, child: Text("Save Movie")),
            ],
          ),
        ),
      ),
    );
  }
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