import 'package:flutter/material.dart';
import 'package:neuroaid/src/core/theme/app_colors.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 2,
    vsync: this,
  );

  final List<Map<String, String>> _faqs = [
    {
      'question': 'How do I book an appointment?',
      'answer':
          'To book an appointment:\n1. Browse doctors by specialty\n2. Select your preferred doctor\n3. Choose available date and time\n4. Confirm your booking\n5. You\'ll receive a confirmation notification',
    },
    {
      'question': 'Can I cancel or reschedule my appointment?',
      'answer':
          'Yes! You can cancel or reschedule up to 24 hours before your appointment. Go to "My Appointments" and select the appointment you want to modify.',
    },
    {
      'question': 'What payment methods are accepted?',
      'answer':
          'We accept:\n• Credit/Debit cards (Visa, Mastercard)\n• Mobile wallets\n• Cash payment at clinic\n\nAll online payments are secure and encrypted.',
    },
    {
      'question': 'How do I access my medical records?',
      'answer':
          'Your medical records are available in the "Health Records" section of your profile. You can view test results, prescriptions, and consultation notes.',
    },
    {
      'question': 'What is the refund policy?',
      'answer':
          'Refunds are processed within 5-7 business days for:\n• Cancelled appointments (24+ hours notice)\n• Doctor cancellations\n\nRefunds are credited to your original payment method.',
    },
    {
      'question': 'How does the AI Assistant work?',
      'answer':
          'Our AI Assistant helps you:\n• Analyze symptoms\n• Get health tips\n• Find the right specialist\n• Answer health questions\n\nNote: AI advice is not a substitute for professional medical consultation.',
    },
  ];

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Help Center'),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(icon: Icon(Icons.help_outline), text: 'FAQ'),
            Tab(icon: Icon(Icons.contact_support_outlined), text: 'Contact Us'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildFAQTab(), _buildContactTab()],
      ),
    );
  }

  Widget _buildFAQTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _faqs.length,
      itemBuilder: (context, index) {
        final faq = _faqs[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.question_answer,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              title: Text(
                faq['question']!,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    faq['answer']!,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContactTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Contact Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Icon(Icons.support_agent, size: 60, color: Colors.white),
              const SizedBox(height: 12),
              const Text(
                'We\'re Here to Help!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Get in touch with our support team',
                style: TextStyle(color: Colors.white.withOpacity(0.9)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Contact Methods
        _ContactCard(
          icon: Icons.phone,
          title: 'Phone Support',
          subtitle: '+20 123 456 7890',
          description: 'Available 24/7',
          color: AppColors.success,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Calling support...'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
        const SizedBox(height: 12),

        _ContactCard(
          icon: Icons.email,
          title: 'Email Support',
          subtitle: 'support@neuroaid.com',
          description: 'Response within 24 hours',
          color: AppColors.primary,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Opening email...'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
        const SizedBox(height: 12),

        _ContactCard(
          icon: Icons.chat_bubble,
          title: 'Live Chat',
          subtitle: 'Chat with us now',
          description: 'Average response: 2 minutes',
          color: AppColors.warning,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Opening chat...'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
        const SizedBox(height: 24),

        // Social Media
        Text(
          'Follow Us',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _SocialButton(
                icon: Icons.facebook,
                label: 'Facebook',
                color: const Color(0xFF1877F2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SocialButton(
                icon: Icons.camera_alt,
                label: 'Instagram',
                color: const Color(0xFFE4405F),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SocialButton(
                icon: Icons.chat,
                label: 'WhatsApp',
                color: const Color(0xFF25D366),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SocialButton(
                icon: Icons.language,
                label: 'Website',
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _ContactCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: color, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening $label...'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}
