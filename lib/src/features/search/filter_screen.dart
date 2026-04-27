import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:neuroaid/src/core/theme/app_colors.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  // Consultation Type
  String _consultationType = 'Online';

  // Budget Range
  RangeValues _budgetRange = const RangeValues(200, 2000);

  // Reviews
  double _minRating = 4.5;

  // Experience
  String _experience = '3-5 years';

  // Availability
  String _availability = 'Available Today';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Filtration',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Consultation Type
                  _buildSectionTitle('Consultation Type'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildChoiceChip(
                        'Online',
                        _consultationType == 'Online',
                        () => setState(() => _consultationType = 'Online'),
                      ),
                      const SizedBox(width: 12),
                      _buildChoiceChip(
                        'In-Person',
                        _consultationType == 'In-Person',
                        () => setState(() => _consultationType = 'In-Person'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Budget Range
                  _buildSectionTitle('Budget Range'),
                  const SizedBox(height: 12),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor: AppColors.primary.withOpacity(0.2),
                      thumbColor: AppColors.primary,
                      overlayColor: AppColors.primary.withOpacity(0.2),
                      valueIndicatorColor: AppColors.primary,
                      trackHeight: 4,
                    ),
                    child: RangeSlider(
                      values: _budgetRange,
                      min: 200,
                      max: 2000,
                      divisions: 18,
                      labels: RangeLabels(
                        '\$${_budgetRange.start.round()}',
                        '\$${_budgetRange.end.round()}',
                      ),
                      onChanged: (values) {
                        setState(() => _budgetRange = values);
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$200',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '\$250',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '\$500',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '\$750',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '\$1000',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '\$2000',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Reviews
                  _buildSectionTitle('Reviews'),
                  const SizedBox(height: 12),
                  _buildRatingOption(4.5, '4.5 and above'),
                  _buildRatingOption(4.0, '4.0 - 4.4'),
                  _buildRatingOption(3.5, '3.5 - 3.9'),
                  _buildRatingOption(3.0, '3.0 - 3.4'),
                  _buildRatingOption(2.5, '2.5 - 2.9'),
                  const SizedBox(height: 32),

                  // Doctor's Experience
                  _buildSectionTitle('Doctor\'s Experience'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildChoiceChip(
                        '0-2 years',
                        _experience == '0-2 years',
                        () => setState(() => _experience = '0-2 years'),
                      ),
                      _buildChoiceChip(
                        '3-5 years',
                        _experience == '3-5 years',
                        () => setState(() => _experience = '3-5 years'),
                      ),
                      _buildChoiceChip(
                        '6-10 years',
                        _experience == '6-10 years',
                        () => setState(() => _experience = '6-10 years'),
                      ),
                      _buildChoiceChip(
                        '11-15 years',
                        _experience == '11-15 years',
                        () => setState(() => _experience = '11-15 years'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Availability
                  _buildSectionTitle('Availability'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildChoiceChip(
                        'Available Today',
                        _availability == 'Available Today',
                        () => setState(() => _availability = 'Available Today'),
                      ),
                      _buildChoiceChip(
                        'Available This Week',
                        _availability == 'Available This Week',
                        () => setState(
                          () => _availability = 'Available This Week',
                        ),
                      ),
                      _buildChoiceChip(
                        'Weekend Available',
                        _availability == 'Weekend Available',
                        () =>
                            setState(() => _availability = 'Weekend Available'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Bottom Buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _consultationType = 'Online';
                        _budgetRange = const RangeValues(200, 2000);
                        _minRating = 4.5;
                        _experience = '3-5 years';
                        _availability = 'Available Today';
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Reset Filter',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Apply filters and return to previous screen
                      Navigator.pop(context, {
                        'consultationType': _consultationType,
                        'budgetRange': _budgetRange,
                        'minRating': _minRating,
                        'experience': _experience,
                        'availability': _availability,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Apply',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildChoiceChip(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildRatingOption(double rating, String label) {
    final isSelected = _minRating == rating;
    return InkWell(
      onTap: () => setState(() => _minRating = rating),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Row(
              children: List.generate(
                5,
                (index) => Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: FaIcon(
                    FontAwesomeIcons.solidStar,
                    size: 16,
                    color: Colors.amber,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              const FaIcon(
                FontAwesomeIcons.circleCheck,
                color: AppColors.primary,
                size: 20,
              )
            else
              FaIcon(
                FontAwesomeIcons.circle,
                color: Colors.grey.shade300,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
