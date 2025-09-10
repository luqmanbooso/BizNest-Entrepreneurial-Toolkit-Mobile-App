import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:get/get.dart';
import '../../utils/theme.dart';

class LegalScreen extends StatefulWidget {
  const LegalScreen({super.key});

  @override
  _LegalScreenState createState() => _LegalScreenState();
}

class _LegalScreenState extends State<LegalScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Legal Compliance'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(text: 'Documents'),
            Tab(text: 'Compliance'),
            Tab(text: 'Legal Help'),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.secondaryColor.withOpacity(0.05), Colors.white],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildDocumentsTab(),
            _buildComplianceTab(),
            _buildLegalHelpTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(
            child: const Text(
              'Legal Document Templates',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 10),
          FadeInDown(
            delay: const Duration(milliseconds: 200),
            child: Text(
              'Professional legal templates for your business',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 30),
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: _buildDocumentCategory(
              'Business Formation',
              'Essential documents to start your business',
              [
                DocumentTemplate(
                  'Articles of Incorporation',
                  'LLC/Corporation formation',
                  Icons.business,
                  true,
                ),
                DocumentTemplate(
                  'Operating Agreement',
                  'LLC operating guidelines',
                  Icons.description,
                  true,
                ),
                DocumentTemplate(
                  'Bylaws Template',
                  'Corporate governance rules',
                  Icons.rule,
                  false,
                ),
                DocumentTemplate(
                  'EIN Application',
                  'Federal tax ID number',
                  Icons.badge,
                  true,
                ),
              ],
              AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          FadeInUp(
            delay: const Duration(milliseconds: 600),
            child: _buildDocumentCategory(
              'Contracts & Agreements',
              'Protect your business relationships',
              [
                DocumentTemplate(
                  'Service Agreement',
                  'Client service contracts',
                  Icons.handshake,
                  true,
                ),
                DocumentTemplate(
                  'Employment Contract',
                  'Employee agreements',
                  Icons.work,
                  true,
                ),
                DocumentTemplate(
                  'NDA Template',
                  'Non-disclosure agreements',
                  Icons.security,
                  true,
                ),
                DocumentTemplate(
                  'Partnership Agreement',
                  'Business partnerships',
                  Icons.group,
                  false,
                ),
              ],
              AppTheme.accentColor,
            ),
          ),
          const SizedBox(height: 20),
          FadeInUp(
            delay: const Duration(milliseconds: 800),
            child: _buildDocumentCategory(
              'Intellectual Property',
              'Protect your ideas and creations',
              [
                DocumentTemplate(
                  'Trademark Application',
                  'Brand protection',
                  Icons.verified,
                  false,
                ),
                DocumentTemplate(
                  'Copyright Notice',
                  'Content protection',
                  Icons.copyright,
                  true,
                ),
                DocumentTemplate(
                  'Work for Hire',
                  'IP ownership agreements',
                  Icons.assignment,
                  true,
                ),
                DocumentTemplate(
                  'License Agreement',
                  'IP licensing terms',
                  Icons.key,
                  false,
                ),
              ],
              AppTheme.successColor,
            ),
          ),
          const SizedBox(height: 20),
          FadeInUp(
            delay: const Duration(milliseconds: 1000),
            child: _buildDocumentCategory(
              'Privacy & Terms',
              'Website and app legal requirements',
              [
                DocumentTemplate(
                  'Privacy Policy',
                  'Data protection compliance',
                  Icons.privacy_tip,
                  true,
                ),
                DocumentTemplate(
                  'Terms of Service',
                  'User agreement terms',
                  Icons.policy,
                  true,
                ),
                DocumentTemplate(
                  'Cookie Policy',
                  'Website cookie usage',
                  Icons.cookie,
                  true,
                ),
                DocumentTemplate(
                  'GDPR Compliance',
                  'European data protection',
                  Icons.shield,
                  false,
                ),
              ],
              AppTheme.warningColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCategory(
    String title,
    String description,
    List<DocumentTemplate> documents,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.folder, color: color, size: 24),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      description,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...documents.map((doc) => _buildDocumentItem(doc, color)),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(DocumentTemplate doc, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(doc.icon, color: color, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        doc.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (doc.isFree)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'FREE',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.warningColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'PRO',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                Text(
                  doc.description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _downloadDocument(doc),
            icon: Icon(Icons.download, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          FadeInDown(child: _buildComplianceOverview()),
          const SizedBox(height: 30),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: _buildComplianceChecklist(),
          ),
          const SizedBox(height: 30),
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: _buildRegulatoryUpdates(),
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceOverview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.accentColor],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Compliance Status',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: _buildComplianceMetric('Completed', '85%')),
              Expanded(child: _buildComplianceMetric('Pending', '3 items')),
              Expanded(child: _buildComplianceMetric('Overdue', '1 item')),
            ],
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: 0.85,
            backgroundColor: Colors.white30,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          const SizedBox(height: 10),
          const Text(
            'Your business is 85% compliant with current regulations',
            style: TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildComplianceChecklist() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Compliance Checklist',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          _buildChecklistItem(
            'Business License',
            'Current and valid',
            true,
            AppTheme.successColor,
          ),
          _buildChecklistItem(
            'Tax Registration',
            'State and federal',
            true,
            AppTheme.successColor,
          ),
          _buildChecklistItem(
            'Workers\' Compensation',
            'If you have employees',
            false,
            AppTheme.warningColor,
          ),
          _buildChecklistItem(
            'Industry Permits',
            'Specific to your business type',
            true,
            AppTheme.successColor,
          ),
          _buildChecklistItem(
            'Data Protection',
            'GDPR/CCPA compliance',
            false,
            AppTheme.errorColor,
          ),
          _buildChecklistItem(
            'Insurance Coverage',
            'General liability insurance',
            true,
            AppTheme.successColor,
          ),
          _buildChecklistItem(
            'Employment Law',
            'Labor law compliance',
            false,
            AppTheme.warningColor,
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(
    String title,
    String description,
    bool isCompleted,
    Color statusColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isCompleted ? statusColor.withOpacity(0.05) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted ? statusColor.withOpacity(0.3) : Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isCompleted ? statusColor : Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : const Icon(Icons.close, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? Colors.black87 : Colors.grey[600],
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isCompleted ? Colors.grey[600] : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          if (!isCompleted)
            TextButton(
              onPressed: () => _handleComplianceAction(title),
              child: Text(
                'Fix',
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRegulatoryUpdates() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Regulatory Updates',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          _buildUpdateItem(
            'New Data Privacy Regulations',
            'Updated CCPA requirements for businesses',
            'March 15, 2024',
            AppTheme.warningColor,
          ),
          _buildUpdateItem(
            'Tax Code Changes',
            'Small business tax deduction updates',
            'March 10, 2024',
            AppTheme.accentColor,
          ),
          _buildUpdateItem(
            'Employment Law Update',
            'Minimum wage increases in several states',
            'March 5, 2024',
            AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateItem(
    String title,
    String description,
    String date,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.notification_important, color: color, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  date,
                  style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _viewUpdateDetails(title),
            icon: Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalHelpTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          FadeInDown(child: _buildLegalConsultation()),
          const SizedBox(height: 30),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: _buildLegalResourcesSection(),
          ),
          const SizedBox(height: 30),
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: _buildLegalFAQ(),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalConsultation() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.secondaryColor, AppTheme.primaryColor],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.gavel, color: Colors.white, size: 32),
              const SizedBox(width: 15),
              const Expanded(
                child: Text(
                  'Need Legal Advice?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Text(
            'Connect with qualified business attorneys for personalized legal guidance.',
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _scheduleConsultation(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Schedule Consultation',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              ElevatedButton(
                onPressed: () => _askLegalQuestion(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white24,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Icon(Icons.chat),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegalResourcesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Legal Resources',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          _buildResourceItem(
            'Business Structure Guide',
            'Choose the right entity type',
            Icons.business,
            AppTheme.primaryColor,
          ),
          _buildResourceItem(
            'Contract Law Basics',
            'Understanding business contracts',
            Icons.description,
            AppTheme.accentColor,
          ),
          _buildResourceItem(
            'Intellectual Property',
            'Protecting your ideas',
            Icons.security,
            AppTheme.successColor,
          ),
          _buildResourceItem(
            'Employment Law',
            'Hiring and managing employees',
            Icons.group,
            AppTheme.warningColor,
          ),
        ],
      ),
    );
  }

  Widget _buildResourceItem(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: color, size: 16),
        ],
      ),
    );
  }

  Widget _buildLegalFAQ() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Frequently Asked Questions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          _buildFAQItem(
            'Do I need a lawyer to start my business?',
            'While not always required, legal consultation can help avoid costly mistakes.',
          ),
          _buildFAQItem(
            'What\'s the difference between LLC and Corporation?',
            'LLCs offer flexibility while corporations provide more structure and investment options.',
          ),
          _buildFAQItem(
            'How do I protect my business name?',
            'Register trademarks and check domain availability to protect your brand.',
          ),
          _buildFAQItem(
            'What contracts do I need for my business?',
            'Essential contracts include service agreements, employment contracts, and NDAs.',
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  void _downloadDocument(DocumentTemplate doc) {
    if (doc.isFree) {
      Get.snackbar(
        'Download Started',
        '${doc.name} is being downloaded...',
        backgroundColor: AppTheme.successColor,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Premium Required',
        'Upgrade to Pro to access ${doc.name}',
        backgroundColor: AppTheme.warningColor,
        colorText: Colors.white,
      );
    }
  }

  void _handleComplianceAction(String item) {
    Get.snackbar(
      'Compliance Action',
      'Opening guidance for $item...',
      backgroundColor: AppTheme.primaryColor,
      colorText: Colors.white,
    );
  }

  void _viewUpdateDetails(String update) {
    Get.snackbar(
      'Regulatory Update',
      'Viewing details for $update...',
      backgroundColor: AppTheme.accentColor,
      colorText: Colors.white,
    );
  }

  void _scheduleConsultation() {
    Get.snackbar(
      'Legal Consultation',
      'Connecting you with available attorneys...',
      backgroundColor: AppTheme.primaryColor,
      colorText: Colors.white,
    );
  }

  void _askLegalQuestion() {
    Get.snackbar(
      'Legal Q&A',
      'Opening legal chat support...',
      backgroundColor: AppTheme.accentColor,
      colorText: Colors.white,
    );
  }
}

class DocumentTemplate {
  final String name;
  final String description;
  final IconData icon;
  final bool isFree;

  DocumentTemplate(this.name, this.description, this.icon, this.isFree);
}
