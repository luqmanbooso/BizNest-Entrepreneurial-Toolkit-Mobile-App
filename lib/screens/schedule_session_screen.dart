import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/modern_theme.dart';
import '../core/services/session_service.dart';

class ScheduleSessionScreen extends StatefulWidget {
  const ScheduleSessionScreen({super.key});

  @override
  State<ScheduleSessionScreen> createState() => _ScheduleSessionScreenState();
}

class _ScheduleSessionScreenState extends State<ScheduleSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _topicController = TextEditingController();
  final _meetingLinkController = TextEditingController();
  final _notesController = TextEditingController();

  List<Map<String, dynamic>> _mentees = [];
  Map<String, dynamic>? _selectedMentee;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  int _selectedDuration = 60;
  bool _isLoading = false;
  bool _isLoadingMentees = true;

  final List<int> _durationOptions = [30, 45, 60, 90, 120];

  @override
  void initState() {
    super.initState();
    _loadMentees();
  }

  Future<void> _loadMentees() async {
    setState(() => _isLoadingMentees = true);
    try {
      final mentees = await SessionService.getMentorMentees();
      setState(() {
        _mentees = mentees;
        _isLoadingMentees = false;
      });
    } catch (e) {
      setState(() => _isLoadingMentees = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading mentees: $e')),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: ModernTheme.electricBlue,
              onPrimary: Colors.white,
              onSurface: ModernTheme.navy,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: ModernTheme.electricBlue,
              onPrimary: Colors.white,
              onSurface: ModernTheme.navy,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _scheduleSession() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMentee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a mentee')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final timeString = _selectedTime.format(context);
      final menteeName = _selectedMentee!['name'] ?? 'Unnamed Mentee';

      await SessionService.createSession(
        menteeId: _selectedMentee!['id'],
        menteeName: menteeName,
        sessionTitle: _titleController.text.trim(),
        sessionTopic: _topicController.text.trim(),
        scheduledDate: _selectedDate,
        scheduledTime: timeString,
        durationMinutes: _selectedDuration,
        meetingLink: _meetingLinkController.text.trim(),
        notes: _notesController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session scheduled successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error scheduling session: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _topicController.dispose();
    _meetingLinkController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: ModernTheme.electricBlue,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: ModernTheme.electricBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Schedule Session',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: _isLoadingMentees
            ? const Center(child: CircularProgressIndicator())
            : _mentees.isEmpty
                ? _buildEmptyState()
                : _buildForm(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'No Mentees Available',
              style: ModernTheme.h3.copyWith(color: ModernTheme.navy),
            ),
            const SizedBox(height: 12),
            Text(
              'You need to have accepted mentorship requests before scheduling sessions.',
              textAlign: TextAlign.center,
              style: ModernTheme.bodyMedium.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: ModernTheme.electricBlue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Select Mentee'),
            const SizedBox(height: 12),
            _buildMenteeSelector(),
            const SizedBox(height: 24),
            _buildSectionTitle('Session Details'),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _titleController,
              label: 'Session Title',
              hint: 'e.g., Business Strategy Review',
              icon: Icons.title,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a session title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _topicController,
              label: 'Topic',
              hint: 'e.g., Marketing Strategy, Funding',
              icon: Icons.topic,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a topic';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Schedule'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildDateSelector()),
                const SizedBox(width: 12),
                Expanded(child: _buildTimeSelector()),
              ],
            ),
            const SizedBox(height: 16),
            _buildDurationSelector(),
            const SizedBox(height: 24),
            _buildSectionTitle('Meeting Link'),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _meetingLinkController,
              label: 'MS Teams / Meeting Link',
              hint: 'https://teams.microsoft.com/...',
              icon: Icons.link,
              keyboardType: TextInputType.url,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a meeting link';
                }
                if (!value.contains('http')) {
                  return 'Please enter a valid URL';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Notes (Optional)'),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _notesController,
              label: 'Additional Notes',
              hint: 'Any preparation needed, agenda, etc.',
              icon: Icons.note,
              maxLines: 4,
            ),
            const SizedBox(height: 32),
            _buildScheduleButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: ModernTheme.h4.copyWith(
        color: ModernTheme.navy,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildMenteeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonFormField<Map<String, dynamic>>(
        initialValue: _selectedMentee,
        isExpanded: true, // Fix overflow issue
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.person, color: ModernTheme.electricBlue),
        ),
        hint: const Text('Select a mentee'),
        items: _mentees.map((mentee) {
          final name = mentee['name'] ?? 'Unnamed Mentee';
          final businessName = mentee['business_name'];
          final hasBusinessName = businessName != null &&
              businessName.toString().isNotEmpty &&
              businessName != 'null';

          // Create display text with business name if available
          final displayText = hasBusinessName ? '$name ($businessName)' : name;

          return DropdownMenuItem(
            value: mentee,
            child: Text(
              displayText,
              style: const TextStyle(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedMentee = value;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please select a mentee';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: ModernTheme.electricBlue),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
      ),
    );
  }

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today,
                    color: ModernTheme.electricBlue, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Date',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector() {
    return GestureDetector(
      onTap: _selectTime,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.access_time,
                    color: ModernTheme.electricBlue, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Time',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _selectedTime.format(context),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.timelapse,
                  color: ModernTheme.electricBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                'Duration',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: _durationOptions.map((duration) {
              final isSelected = _selectedDuration == duration;
              return ChoiceChip(
                label: Text('$duration min'),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedDuration = duration;
                    });
                  }
                },
                selectedColor: ModernTheme.electricBlue,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : ModernTheme.navy,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _scheduleSession,
        style: ElevatedButton.styleFrom(
          backgroundColor: ModernTheme.electricBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Schedule Session',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
