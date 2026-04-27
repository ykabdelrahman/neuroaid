import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:neuroaid/src/core/theme/app_colors.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  bool saveAsDefault = false;
  bool _isLoading = false;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future<void> _handleSaveCard() async {
    if (formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Card added successfully!'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Add New Card'), centerTitle: false),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Credit Card Widget
            CreditCardWidget(
              cardNumber: cardNumber,
              expiryDate: expiryDate,
              cardHolderName: cardHolderName,
              cvvCode: cvvCode,
              showBackView: isCvvFocused,
              isHolderNameVisible: true,
              onCreditCardWidgetChange: (_) {},
              cardBgColor: AppColors.primary,
              obscureCardNumber: true,
              obscureCardCvv: true,
              isSwipeGestureEnabled: true,
              customCardTypeIcons: <CustomCardTypeIcon>[],
            ),

            // Form
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.security,
                          color: AppColors.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Your card information is encrypted and secure',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Credit Card Form
                  CreditCardForm(
                    formKey: formKey,
                    cardNumber: cardNumber,
                    expiryDate: expiryDate,
                    cardHolderName: cardHolderName,
                    cvvCode: cvvCode,
                    onCreditCardModelChange: (CreditCardModel model) {
                      setState(() {
                        cardNumber = model.cardNumber;
                        expiryDate = model.expiryDate;
                        cardHolderName = model.cardHolderName;
                        cvvCode = model.cvvCode;
                        isCvvFocused = model.isCvvFocused;
                      });
                    },
                    obscureCvv: true,
                    obscureNumber: false,
                    isHolderNameVisible: true,
                    isCardNumberVisible: true,
                    isExpiryDateVisible: true,
                    enableCvv: true,
                    cvvValidationMessage: 'Please enter a valid CVV',
                    dateValidationMessage: 'Please enter a valid expiry date',
                    numberValidationMessage: 'Please enter a valid card number',
                    cardNumberValidator: (String? cardNumber) {
                      return null;
                    },
                    expiryDateValidator: (String? expiryDate) {
                      return null;
                    },
                    cvvValidator: (String? cvv) {
                      return null;
                    },
                    cardHolderValidator: (String? cardHolderName) {
                      return null;
                    },
                    inputConfiguration: const InputConfiguration(
                      cardNumberDecoration: InputDecoration(
                        labelText: 'Card Number',
                        hintText: 'XXXX XXXX XXXX XXXX',
                      ),
                      expiryDateDecoration: InputDecoration(
                        labelText: 'Expiry Date',
                        hintText: 'MM/YY',
                      ),
                      cvvCodeDecoration: InputDecoration(
                        labelText: 'CVV',
                        hintText: 'XXX',
                      ),
                      cardHolderDecoration: InputDecoration(
                        labelText: 'Card Holder Name',
                        hintText: 'Enter your name',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Save as Default
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: saveAsDefault,
                          onChanged: (value) {
                            setState(() => saveAsDefault = value ?? false);
                          },
                          activeColor: AppColors.primary,
                        ),
                        Expanded(
                          child: Text(
                            'Set as default payment method',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSaveCard,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text('Save Card'),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Accepted Cards
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'We Accept',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _CardBrandIcon(Icons.credit_card, 'Visa'),
                            const SizedBox(width: 12),
                            _CardBrandIcon(Icons.credit_card, 'Mastercard'),
                            const SizedBox(width: 12),
                            _CardBrandIcon(Icons.credit_card, 'Amex'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardBrandIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const _CardBrandIcon(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
