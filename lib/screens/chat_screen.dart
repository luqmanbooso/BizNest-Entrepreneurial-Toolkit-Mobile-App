import 'package:flutter/material.dart';
import '../core/theme/modern_theme.dart';

class ChatScreen extends StatelessWidget {
  final String? entrepreneurName;
  final String? entrepreneurAvatar;
  final String? businessName;

  const ChatScreen({super.key, this.entrepreneurName, this.entrepreneurAvatar, this.businessName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(entrepreneurName ?? 'Chat'),
        backgroundColor: ModernTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text('Chat with ${entrepreneurName ?? 'user'} coming soon...'),
      ),
    );
  }
}