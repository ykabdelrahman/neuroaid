import 'package:flutter/material.dart';
import 'package:neuroaid/src/core/routes/app_router.dart';
import 'package:neuroaid/src/core/theme/app_colors.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  String? _selectedMethod;

  final List<Map<String, dynamic>> _savedCards = [
    {
      'id': '1',
      'type': 'Visa',
      'last4': '4242',
      'expiry': '12/25',
      'isDefault': true,
    },
    {
      'id': '2',
      'type': 'Mastercard',
      'last4': '8888',
      'expiry': '06/26',
      'isDefault': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Payment Method'), centerTitle: false),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Saved Cards Section
          if (_savedCards.isNotEmpty) ...[
            Text(
              'Saved Cards',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ..._savedCards.map(
              (card) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _SavedCardItem(
                  card: card,
                  isSelected: _selectedMethod == card['id'],
                  onTap: () => setState(() => _selectedMethod = card['id']),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Add New Card
          _PaymentOption(
            icon: Icons.add_card,
            title: 'Add New Card',
            subtitle: 'Credit or Debit Card',
            color: AppColors.primary,
            isSelected: _selectedMethod == 'new_card',
            onTap: () {
              Navigator.pushNamed(context, AppRouter.addCard);
            },
          ),
          const SizedBox(height: 24),

          // Other Payment Methods
          Text(
            'Other Payment Methods',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          _PaymentOption(
            icon: Icons.account_balance_wallet,
            title: 'Digital Wallet',
            subtitle: 'Apple Pay, Google Pay',
            color: AppColors.success,
            isSelected: _selectedMethod == 'wallet',
            onTap: () => setState(() => _selectedMethod = 'wallet'),
          ),
          const SizedBox(height: 12),

          _PaymentOption(
            icon: Icons.paypal,
            title: 'PayPal',
            subtitle: 'Pay with PayPal account',
            color: const Color(0xFF0070BA),
            isSelected: _selectedMethod == 'paypal',
            onTap: () => setState(() => _selectedMethod = 'paypal'),
          ),
          const SizedBox(height: 12),

          _PaymentOption(
            icon: Icons.money,
            title: 'Cash',
            subtitle: 'Pay at clinic',
            color: AppColors.warning,
            isSelected: _selectedMethod == 'cash',
            onTap: () => setState(() => _selectedMethod = 'cash'),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _selectedMethod != null
                ? () => Navigator.pushNamed(context, AppRouter.paymentSummary)
                : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Continue'),
          ),
        ),
      ),
    );
  }
}

class _SavedCardItem extends StatelessWidget {
  final Map<String, dynamic> card;
  final bool isSelected;
  final VoidCallback onTap;

  const _SavedCardItem({
    required this.card,
    required this.isSelected,
    required this.onTap,
  });

  IconData get _cardIcon {
    switch (card['type']) {
      case 'Visa':
        return Icons.credit_card;
      case 'Mastercard':
        return Icons.credit_card;
      default:
        return Icons.credit_card;
    }
  }

  Color get _cardColor {
    switch (card['type']) {
      case 'Visa':
        return const Color(0xFF1A1F71);
      case 'Mastercard':
        return const Color(0xFFEB001B);
      default:
        return AppColors.primary;
    }
  }

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
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _cardColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_cardIcon, color: _cardColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        card['type'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      if (card['isDefault']) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Default',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '•••• •••• •••• ${card['last4']}',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Expires ${card['expiry']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              )
            else
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border, width: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isSelected,
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
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
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
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              )
            else
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border, width: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
