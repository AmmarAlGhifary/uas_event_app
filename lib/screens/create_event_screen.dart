import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:uas_event_app/api/api_service.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _categoryController = TextEditingController();
  final _maxAttendeesController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();

  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  bool _isSubmitting = false;
  final ApiService _apiService = ApiService();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _categoryController.dispose();
    _maxAttendeesController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedStartDate == null || _selectedEndDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Silakan pilih tanggal mulai dan selesai.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      setState(() => _isSubmitting = true);

      try {
        final DateFormat apiDateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
        final String startDateString = apiDateFormat.format(
          _selectedStartDate!,
        );
        final String endDateString = apiDateFormat.format(_selectedEndDate!);

        await _apiService.createEvent(
          title: _titleController.text,
          description: _descriptionController.text,
          startDate: startDateString,
          endDate: endDateString,
          location: _locationController.text,
          category: _categoryController.text,
          maxAttendees: int.parse(_maxAttendeesController.text),
          price: int.parse(_priceController.text),
          imageUrl: _imageUrlController.text,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Event berhasil dibuat!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Gagal membuat event: ${e.toString().replaceFirst("Exception: ", "")}',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSubmitting = false);
        }
      }
    }
  }

  Future<void> _pickDateTime(bool isStartDate) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
    );

    if (time == null) return;

    final fullDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      if (isStartDate) {
        _selectedStartDate = fullDateTime;
      } else {
        _selectedEndDate = fullDateTime;
      }
    });
  }

  String _formatDateTimeForDisplay(DateTime? dt) {
    if (dt == null) return '';
    return DateFormat('EEEE, d MMM yyyy HH:mm', 'id_ID').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Event Baru')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextFormField(
                controller: _titleController,
                label: 'Judul Event',
                icon: Icons.title,
              ),
              _buildTextFormField(
                controller: _descriptionController,
                label: 'Deskripsi',
                icon: Icons.description,
                maxLines: 5,
              ),
              _buildTextFormField(
                controller: _locationController,
                label: 'Lokasi',
                icon: Icons.location_on,
              ),
              _buildTextFormField(
                controller: _categoryController,
                label: 'Kategori (e.g., Workshop, Seminar)',
                icon: Icons.category,
              ),
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Tanggal & Waktu Mulai',
                  prefixIcon: const Icon(Icons.calendar_today),
                  hintText: _selectedStartDate == null
                      ? 'Pilih tanggal & waktu'
                      : _formatDateTimeForDisplay(_selectedStartDate),
                ),
                onTap: () => _pickDateTime(true),
              ),
              const SizedBox(height: 16),
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Tanggal & Waktu Selesai',
                  prefixIcon: const Icon(Icons.calendar_month),
                  hintText: _selectedEndDate == null
                      ? 'Pilih tanggal & waktu'
                      : _formatDateTimeForDisplay(_selectedEndDate),
                ),
                onTap: () => _pickDateTime(false),
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _maxAttendeesController,
                label: 'Maksimal Peserta',
                icon: Icons.people,
                keyboardType: TextInputType.number,
                formatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              _buildTextFormField(
                controller: _priceController,
                label: 'Harga (0 jika gratis)',
                icon: Icons.price_change,
                keyboardType: TextInputType.number,
                formatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              _buildTextFormField(
                controller: _imageUrlController,
                label: 'URL Gambar (Opsional)',
                icon: Icons.image,
                validator: null,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitForm,
                icon: _isSubmitting
                    ? const SizedBox.shrink()
                    : const Icon(Icons.save),
                label: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Simpan Event'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? formatters,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: formatters,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        validator:
            validator ??
            (value) {
              if (value == null || value.isEmpty) {
                return '$label tidak boleh kosong.';
              }
              return null;
            },
      ),
    );
  }
}
