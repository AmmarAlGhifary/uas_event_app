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
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

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
    _startDateController.dispose(); // Don't forget to dispose new controllers
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      if (_selectedStartDate == null || _selectedEndDate == null) {
        _showErrorSnackBar('Silakan pilih tanggal mulai dan selesai.');
        return;
      }
      if (_selectedEndDate!.isBefore(_selectedStartDate!)) {
        _showErrorSnackBar(
          'Tanggal selesai tidak boleh sebelum tanggal mulai.',
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
          maxAttendees: int.tryParse(_maxAttendeesController.text) ?? 0,
          price: int.tryParse(_priceController.text) ?? 0,
          imageUrl: _imageUrlController.text,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Event berhasil dibuat!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          _showErrorSnackBar(
            'Gagal membuat event: ${e.toString().replaceFirst("Exception: ", "")}',
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSubmitting = false);
        }
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _pickDateTime(bool isStartDate) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate:
          (isStartDate ? _selectedStartDate : _selectedEndDate) ??
          DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        (isStartDate ? _selectedStartDate : _selectedEndDate) ?? DateTime.now(),
      ),
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
        _startDateController.text = _formatDateTimeForDisplay(fullDateTime);
      } else {
        _selectedEndDate = fullDateTime;
        _endDateController.text = _formatDateTimeForDisplay(fullDateTime);
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
      body: Form(
        key: _formKey,
        child: ListView(
          // Use ListView for better scrolling with many fields
          padding: const EdgeInsets.all(16.0),
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
              icon: Icons.location_on_outlined,
            ),
            _buildTextFormField(
              controller: _categoryController,
              label: 'Kategori (e.g., Workshop, Seminar)',
              icon: Icons.category_outlined,
            ),
            // --- UPDATED DATE FIELDS ---
            _buildTextFormField(
              controller: _startDateController,
              label: 'Tanggal & Waktu Mulai',
              icon: Icons.calendar_today_outlined,
              readOnly: true,
              onTap: () => _pickDateTime(true),
            ),
            _buildTextFormField(
              controller: _endDateController,
              label: 'Tanggal & Waktu Selesai',
              icon: Icons.calendar_month_outlined,
              readOnly: true,
              onTap: () => _pickDateTime(false),
            ),
            _buildTextFormField(
              controller: _maxAttendeesController,
              label: 'Maksimal Peserta',
              icon: Icons.people_outline,
              keyboardType: TextInputType.number,
              formatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            _buildTextFormField(
              controller: _priceController,
              label: 'Harga (Isi 0 jika gratis)',
              icon: Icons.price_change_outlined,
              keyboardType: TextInputType.number,
              formatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            _buildTextFormField(
              controller: _imageUrlController,
              label: 'URL Gambar (Opsional)',
              icon: Icons.image_outlined,
              validator: null, // Optional field doesn't need a validator
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submitForm,
              icon: _isSubmitting
                  ? const SizedBox.shrink()
                  : const Icon(Icons.save_outlined),
              label: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Simpan Event'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
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
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: formatters,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
          filled: readOnly,
          fillColor: readOnly ? Colors.grey.withOpacity(0.05) : null,
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
