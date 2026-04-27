import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const FaIcon(
            FontAwesomeIcons.chevronLeft,
            size: 20,
            color: Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildParagraph(
              'Your privacy is important to us. It is Brainstorming\'s policy to respect your privacy regarding any information we may collect from you.',
            ),
            const SizedBox(height: 16),
            _buildParagraph(
              'We only ask for personal information when we truly need it to provide a service to you. We collect it by fair and lawful means, with your knowledge and consent. We also let you know why we\'re collecting it and how it will be used.',
            ),
            const SizedBox(height: 16),
            _buildParagraph(
              'We only retain collected information for as long as necessary to provide you with your requested service. What data we store, we\'ll protect within commercially acceptable means to prevent loss and theft, as well as unauthorized access, disclosure, copying, use or modification.',
            ),
            const SizedBox(height: 16),
            _buildParagraph(
              'We don\'t share any personally identifying information publicly or with third-parties, except when required to by law.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 15, height: 1.6, color: Colors.grey.shade800),
    );
  }
}
