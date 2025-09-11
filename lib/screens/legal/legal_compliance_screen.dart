import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LegalComplianceScreen extends StatefulWidget {
  @override
  _LegalComplianceScreenState createState() => _LegalComplianceScreenState();
}

class _LegalComplianceScreenState extends State<LegalComplianceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Legal Compliance'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLegalOverview(),
                const SizedBox(height: 30),
                _buildDocumentsList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegalOverview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFEC4899)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Legal Compliance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Manage your legal documents and ensure compliance with regulations.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Legal Documents',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 20),
        _buildDocumentCard('Business Registration', 'Articles of Incorporation',
            Icons.business_rounded),
        _buildDocumentCard('Operating Agreement', 'LLC Operating Agreement',
            Icons.gavel_rounded),
        _buildDocumentCard(
            'Privacy Policy', 'GDPR Compliance', Icons.privacy_tip_rounded),
        _buildDocumentCard(
            'Terms of Service', 'User Agreement', Icons.article_rounded),
      ],
    );
  }

  Widget _buildDocumentCard(String title, String description, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFF59E0B),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  _showDocumentDetails(title, description);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'View',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  _downloadTemplate(title);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Download',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDocumentDetails(String title, String description) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFEC4899)],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDocumentContent(title),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentContent(String title) {
    switch (title) {
      case 'Business Registration':
        return _buildBusinessRegistrationContent();
      case 'Operating Agreement':
        return _buildOperatingAgreementContent();
      case 'Privacy Policy':
        return _buildPrivacyPolicyContent();
      case 'Terms of Service':
        return _buildTermsOfServiceContent();
      default:
        return const Text('Document content not available.');
    }
  }

  Widget _buildBusinessRegistrationContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Business Registration Requirements',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 16),
        _buildContentSection('1. Choose Business Structure', [
          'Sole Proprietorship',
          'Partnership',
          'Limited Liability Company (LLC)',
          'Corporation (C-Corp or S-Corp)',
        ]),
        _buildContentSection('2. Required Documents', [
          'Articles of Incorporation',
          'Operating Agreement',
          'Federal Tax ID (EIN)',
          'Business License',
          'State Registration',
        ]),
        _buildContentSection('3. Next Steps', [
          'File with Secretary of State',
          'Obtain necessary permits',
          'Open business bank account',
          'Register for taxes',
        ]),
      ],
    );
  }

  Widget _buildOperatingAgreementContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'LLC Operating Agreement',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 16),
        _buildContentSection('Key Sections to Include', [
          'Member information and ownership percentages',
          'Management structure and decision-making process',
          'Capital contributions and profit/loss distribution',
          'Transfer of membership interests',
          'Dissolution procedures',
        ]),
        _buildContentSection('Important Considerations', [
          'Customize for your specific business needs',
          'Review with legal counsel',
          'Update as business evolves',
          'Ensure all members sign and date',
        ]),
      ],
    );
  }

  Widget _buildPrivacyPolicyContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Privacy Policy Guidelines',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 16),
        _buildContentSection('GDPR Compliance Requirements', [
          'Data collection transparency',
          'User consent mechanisms',
          'Right to access personal data',
          'Right to rectification',
          'Right to erasure (right to be forgotten)',
          'Data portability rights',
        ]),
        _buildContentSection('Policy Must Include', [
          'Types of data collected',
          'Purpose of data collection',
          'Data sharing practices',
          'Security measures',
          'Contact information for privacy concerns',
        ]),
      ],
    );
  }

  Widget _buildTermsOfServiceContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Terms of Service Template',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 16),
        _buildContentSection('Essential Clauses', [
          'Acceptance of terms',
          'Description of services',
          'User responsibilities',
          'Intellectual property rights',
          'Limitation of liability',
          'Termination conditions',
        ]),
        _buildContentSection('Additional Considerations', [
          'Governing law and jurisdiction',
          'Dispute resolution procedures',
          'Modification of terms',
          'Severability clause',
        ]),
      ],
    );
  }

  Widget _buildContentSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(
                      color: Color(0xFFF59E0B),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )),
        const SizedBox(height: 16),
      ],
    );
  }

  void _downloadTemplate(String title) {
    Get.snackbar(
      'Download Started',
      'Downloading $title template...',
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );

    // Simulate download completion
    Future.delayed(const Duration(seconds: 2), () {
      Get.snackbar(
        'Download Complete',
        '$title template saved to Downloads',
        backgroundColor: const Color(0xFF059669),
        colorText: Colors.white,
      );
    });
  }
}
