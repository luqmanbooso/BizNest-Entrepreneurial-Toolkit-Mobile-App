import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/modern_theme.dart';
import '../core/services/mentorship_service.dart';

class MentorshipRequestScreen extends StatefulWidget {
  final Map<String, dynamic> mentor;

  const MentorshipRequestScreen({
    super.key,
    required this.mentor,
  });

  @override
  State<MentorshipRequestScreen> createState() =>
      _MentorshipRequestScreenState();
}

class _MentorshipRequestScreenState extends State<MentorshipRequestScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _industryController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  String _selectedRequestType = 'One-time Consultation';
  bool _isLoading = false;

  final List<String> _requestTypes = [
    'One-time Consultation',
    'Ongoing Mentorship',
    'Project Review',
    'Strategy Session',
    'Fundraising Guidance',
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _animationController.forward();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _messageController.dispose();
    _industryController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: ModernTheme.electricBlue,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: _buildAppBar(),
        body: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: _buildBody(),
              ),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: ModernTheme.electricBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'Request Mentorship',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMentorCard(),
          const SizedBox(height: 24),
          _buildRequestTypeSection(),
          const SizedBox(height: 24),
          _buildBusinessInfoSection(),
          const SizedBox(height: 24),
          _buildMessageSection(),
          const SizedBox(height: 32),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildMentorCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(widget.mentor['avatar']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.mentor['name'],
                  style: ModernTheme.h3.copyWith(
                    fontWeight: FontWeight.w700,
                    color: ModernTheme.navy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.mentor['title'],
                  style: ModernTheme.bodyMedium.copyWith(
                    color: ModernTheme.mediumGray,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      size: 16,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.mentor['rating']} (${widget.mentor['reviews_count']} reviews)',
                      style: ModernTheme.bodySmall.copyWith(
                        color: ModernTheme.mediumGray,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Type of Mentorship',
          style: ModernTheme.h4.copyWith(
            fontWeight: FontWeight.w600,
            color: ModernTheme.navy,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.withOpacity(0.3),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedRequestType,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down),
              items: _requestTypes.map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(
                    type,
                    style: ModernTheme.bodyMedium.copyWith(
                      color: ModernTheme.navy,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedRequestType = newValue;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Business Information',
          style: ModernTheme.h4.copyWith(
            fontWeight: FontWeight.w600,
            color: ModernTheme.navy,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Help the mentor understand your business background',
          style: ModernTheme.bodyMedium.copyWith(
            color: ModernTheme.mediumGray,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Industry',
                    style: ModernTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: ModernTheme.navy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.3),
                      ),
                    ),
                    child: TextField(
                      controller: _industryController,
                      style: ModernTheme.bodyMedium.copyWith(
                        color: ModernTheme.navy,
                      ),
                      decoration: InputDecoration(
                        hintText: 'e.g. Technology, Healthcare',
                        hintStyle: ModernTheme.bodyMedium.copyWith(
                          color: ModernTheme.mediumGray,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                        prefixIcon: const Icon(
                          Icons.business_outlined,
                          color: ModernTheme.mediumGray,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Location',
                    style: ModernTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: ModernTheme.navy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.3),
                      ),
                    ),
                    child: TextField(
                      controller: _locationController,
                      style: ModernTheme.bodyMedium.copyWith(
                        color: ModernTheme.navy,
                      ),
                      decoration: InputDecoration(
                        hintText: 'e.g. Colombo, Galle, Remote',
                        hintStyle: ModernTheme.bodyMedium.copyWith(
                          color: ModernTheme.mediumGray,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                        prefixIcon: const Icon(
                          Icons.location_on_outlined,
                          color: ModernTheme.mediumGray,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMessageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Message',
          style: ModernTheme.h4.copyWith(
            fontWeight: FontWeight.w600,
            color: ModernTheme.navy,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tell ${widget.mentor['name']} about your business and what you hope to achieve through mentorship.',
          style: ModernTheme.bodyMedium.copyWith(
            color: ModernTheme.mediumGray,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.withOpacity(0.3),
            ),
          ),
          child: TextField(
            controller: _messageController,
            maxLines: 6,
            style: ModernTheme.bodyMedium.copyWith(
              color: ModernTheme.navy,
            ),
            decoration: InputDecoration(
              hintText:
                  'Hi ${widget.mentor['name']}, I\'m interested in your mentorship because...',
              hintStyle: ModernTheme.bodyMedium.copyWith(
                color: ModernTheme.mediumGray,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitRequest,
        style: ElevatedButton.styleFrom(
          backgroundColor: ModernTheme.electricBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                'Send Request',
                style: ModernTheme.h4.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Future<void> _submitRequest() async {
    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please write a message to the mentor'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    if (_industryController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please specify your industry'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    if (_locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please specify your location'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await MentorshipService.sendMentorshipRequest(
        mentorId: widget.mentor['id'],
        message: _messageController.text.trim(),
        requestType: _selectedRequestType,
        industry: _industryController.text.trim(),
        location: _locationController.text.trim(),
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Mentorship request sent to ${widget.mentor['name']}!'),
              backgroundColor: ModernTheme.freshGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        throw Exception('Failed to send request');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to send request. Please try again.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
