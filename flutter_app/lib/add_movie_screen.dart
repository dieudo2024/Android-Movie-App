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
  late TextEditingController _titleController;
  late TextEditingController _categoryController;
  late TextEditingController _directorController;
  late TextEditingController _yearController;
  late TextEditingController _ratingController;
  late TextEditingController _descriptionController;
  late TextEditingController _synopsisController;
  bool _isSubmitting = false;
  String? _errorMessage;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    // PRE-LOADING DATA: Controllers now start with existing data if editing
    _titleController = TextEditingController(text: widget.movieToEdit?.title ?? '');
    _categoryController = TextEditingController(text: widget.movieToEdit?.category ?? '');
    _yearController = TextEditingController(text: widget.movieToEdit?.year.toString() ?? '');
    _ratingController = TextEditingController(text: widget.movieToEdit?.rating.toString() ?? '');
    _synopsisController = TextEditingController(text: widget.movieToEdit?.synopsis ?? '');
    _directorController = TextEditingController(text: widget.movieToEdit?.director ?? '');
    _descriptionController = TextEditingController(text: widget.movieToEdit?.description ?? '');
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      final movie = Movie(
        id: widget.movieToEdit?.id, 
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
        // Calls the update (PUT) method in your ApiService
        success = await apiService.updateMovie(widget.movieToEdit!.id!, movie);
      }

      if (success) {
        // Returns true to signal BrowseScreen to refresh the list
        Navigator.pop(context, true);
      } else {
        setState(() {
          _errorMessage = "Failed to save movie. Check your API.";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error saving movie. Please try again.";
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
                decoration: const InputDecoration(labelText: 'Category *'),
                validator: (v) => v!.isEmpty ? 'Category is required' : null,
              ),
              TextFormField(
                controller: _directorController,
                decoration: const InputDecoration(labelText: 'Director *'),
                validator: (val) => val!.isEmpty ? 'Director is required' : null,
              ),
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(labelText: 'Year *'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Year is required';
                  final year = int.tryParse(v);
                  if (year == null || year < 1888) return 'Invalid year';
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
                controller: _synopsisController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Synopsis *'),
                validator: (val) => val!.isEmpty ? 'Synopsis is required' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description (optional)'),
              ),
              const SizedBox(height: 30),
              if (_errorMessage != null)
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting 
                  ? const CircularProgressIndicator() 
                  : Text(widget.movieToEdit == null ? 'Add Movie' : 'Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _yearController.dispose();
    _ratingController.dispose();
    _synopsisController.dispose();
    _descriptionController.dispose();
    _directorController.dispose();
    super.dispose();
  }
}