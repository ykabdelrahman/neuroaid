import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:neuroaid/src/core/services/api_service.dart';
import 'package:neuroaid/src/features/stroke_assessment/models/detailed_stroke_assessment_request.dart';
import 'package:neuroaid/src/features/stroke_assessment/models/stroke_assessment_response.dart';
import 'package:neuroaid/src/features/stroke_assessment/services/stroke_assessment_service.dart';

class CommonQuestionsAndAnswersScreen extends StatefulWidget {
  const CommonQuestionsAndAnswersScreen({super.key});

  @override
  State<CommonQuestionsAndAnswersScreen> createState() =>
      _CommonQuestionsAndAnswersScreenState();
}

class _CommonQuestionsAndAnswersScreenState
    extends State<CommonQuestionsAndAnswersScreen> {
  final _formKey = GlobalKey<FormState>();
  final StrokeAssessmentService _assessmentService = StrokeAssessmentService(
    GetIt.instance<ApiService>(),
  );

  // Form controllers
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _glucoseController = TextEditingController();
  final TextEditingController _bmiController = TextEditingController();

  // Form state
  String _gender = '';
  int? _hypertension;
  int? _heartDisease;
  String _everMarried = '';
  String _workType = '';
  String _residenceType = '';
  String _smokingStatus = '';

  bool _isLoading = false;
  StrokeAssessmentResponse? _result;

  @override
  void dispose() {
    _ageController.dispose();
    _glucoseController.dispose();
    _bmiController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate all fields
    final validationError = DetailedStrokeAssessmentRequest.validate(
      gender: _gender,
      age: _ageController.text,
      hypertension: _hypertension,
      heartDisease: _heartDisease,
      everMarried: _everMarried,
      workType: _workType,
      residenceType: _residenceType,
      avgGlucoseLevel: _glucoseController.text,
      bmi: _bmiController.text,
      smokingStatus: _smokingStatus,
    );

    if (validationError != null) {
      _showErrorDialog(validationError);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final request = DetailedStrokeAssessmentRequest.fromFormData(
        gender: _gender,
        age: _ageController.text,
        hypertension: _hypertension!,
        heartDisease: _heartDisease!,
        everMarried: _everMarried,
        workType: _workType,
        residenceType: _residenceType,
        avgGlucoseLevel: _glucoseController.text,
        bmi: _bmiController.text,
        smokingStatus: _smokingStatus,
      );

      final response = await _assessmentService.submitDetailedAssessment(
        request,
      );

      setState(() {
        _result = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog(e.toString());
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    setState(() {
      _result = null;
      _gender = '';
      _hypertension = null;
      _heartDisease = null;
      _everMarried = '';
      _workType = '';
      _residenceType = '';
      _smokingStatus = '';
      _ageController.clear();
      _glucoseController.clear();
      _bmiController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
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
          'Stroke Risk Assessment',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _result != null ? _buildResultView() : _buildFormView(),
    );
  }

  Widget _buildFormView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0E7772), Color(0xFF107B92)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FaIcon(
                    FontAwesomeIcons.heartPulse,
                    size: 40,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Medical Assessment Form',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please fill in your medical information accurately',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 1. Gender
            _buildSectionTitle('1. Gender'),
            _buildRadioGroup(
              value: _gender,
              options: const ['Male', 'Female'],
              onChanged: (value) => setState(() => _gender = value!),
            ),

            const SizedBox(height: 20),

            // 2. Age
            _buildSectionTitle('2. Age'),
            _buildNumberInput(
              controller: _ageController,
              hint: 'Enter your age (0-120)',
              icon: FontAwesomeIcons.cakeCandles,
            ),

            const SizedBox(height: 20),

            // 3. Hypertension
            _buildSectionTitle('3. Do you have Hypertension?'),
            _buildRadioGroup(
              value: _hypertension == null
                  ? ''
                  : _hypertension == 1
                  ? 'Yes'
                  : 'No',
              options: const ['Yes', 'No'],
              onChanged: (value) =>
                  setState(() => _hypertension = value == 'Yes' ? 1 : 0),
            ),

            const SizedBox(height: 20),

            // 4. Heart Disease
            _buildSectionTitle('4. Do you have Heart Disease?'),
            _buildRadioGroup(
              value: _heartDisease == null
                  ? ''
                  : _heartDisease == 1
                  ? 'Yes'
                  : 'No',
              options: const ['Yes', 'No'],
              onChanged: (value) =>
                  setState(() => _heartDisease = value == 'Yes' ? 1 : 0),
            ),

            const SizedBox(height: 20),

            // 5. Marital Status
            _buildSectionTitle('5. Are you married?'),
            _buildRadioGroup(
              value: _everMarried,
              options: const ['Yes', 'No'],
              onChanged: (value) => setState(() => _everMarried = value!),
            ),

            const SizedBox(height: 20),

            // 6. Work Type
            _buildSectionTitle('6. Work Type'),
            _buildDropdown(
              value: _workType.isEmpty ? null : _workType,
              hint: 'Select your work type',
              items: const ['Private', 'Self-employed', 'Govt_job', 'children'],
              displayNames: const [
                'Private',
                'Self-employed',
                'Government job',
                'Child / Not working',
              ],
              onChanged: (value) => setState(() => _workType = value!),
              icon: FontAwesomeIcons.briefcase,
            ),

            const SizedBox(height: 20),

            // 7. Residence Type
            _buildSectionTitle('7. Residence Type'),
            _buildRadioGroup(
              value: _residenceType,
              options: const ['Urban', 'Rural'],
              onChanged: (value) => setState(() => _residenceType = value!),
            ),

            const SizedBox(height: 20),

            // 8. Average Glucose Level
            _buildSectionTitle('8. Average Glucose Level (mg/dL)'),
            _buildNumberInput(
              controller: _glucoseController,
              hint: 'Enter glucose level (50-500)',
              icon: FontAwesomeIcons.droplet,
              isDecimal: true,
            ),

            const SizedBox(height: 20),

            // 9. BMI
            _buildSectionTitle('9. Body Mass Index (BMI)'),
            _buildNumberInput(
              controller: _bmiController,
              hint: 'Enter BMI (10-70)',
              icon: FontAwesomeIcons.weightScale,
              isDecimal: true,
            ),

            const SizedBox(height: 20),

            // 10. Smoking Status
            _buildSectionTitle('10. Smoking Status'),
            _buildDropdown(
              value: _smokingStatus.isEmpty ? null : _smokingStatus,
              hint: 'Select smoking status',
              items: const [
                'never smoked',
                'formerly smoked',
                'smokes',
                'Unknown',
              ],
              displayNames: const [
                'Never smoked',
                'Formerly smoked',
                'Currently smokes',
                'Unknown',
              ],
              onChanged: (value) => setState(() => _smokingStatus = value!),
              icon: FontAwesomeIcons.smokingBan,
            ),

            const SizedBox(height: 32),

            // Submit Button
            ElevatedButton(
              onPressed: _isLoading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0E7772),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: Colors.grey.shade300,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Submit Assessment',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildResultView() {
    if (_result == null) return const SizedBox.shrink();

    Color getRiskColor() {
      switch (_result!.riskLevel.toLowerCase()) {
        case 'low':
          return const Color(0xFF10B981);
        case 'medium':
        case 'moderate':
          return const Color(0xFFF59E0B);
        case 'high':
          return const Color(0xFFEF4444);
        default:
          return const Color(0xFF64748B);
      }
    }

    IconData getRiskIcon() {
      switch (_result!.riskLevel.toLowerCase()) {
        case 'low':
          return FontAwesomeIcons.circleCheck;
        case 'medium':
        case 'moderate':
          return FontAwesomeIcons.triangleExclamation;
        case 'high':
          return FontAwesomeIcons.circleExclamation;
        default:
          return FontAwesomeIcons.circleInfo;
      }
    }

    final riskColor = getRiskColor();
    final riskIcon = getRiskIcon();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Result Card
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Risk Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: riskColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: FaIcon(riskIcon, size: 50, color: riskColor),
                ),

                const SizedBox(height: 24),

                // Risk Percentage
                Text(
                  '${_result!.riskPercentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: riskColor,
                  ),
                ),

                const SizedBox(height: 8),

                // Risk Level Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: riskColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _result!.riskCategoryText.toUpperCase(),
                    style: TextStyle(
                      color: riskColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Display Message
                Text(
                  _result!.displayMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 16),

                // Disclaimer
                Text(
                  'This assessment is for informational purposes only and does not replace professional medical advice.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Recommendations
          if (_result!.recommendations.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.lightbulb,
                        size: 20,
                        color: riskColor,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Recommendations',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ..._result!.recommendations.map(
                    (rec) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.circleCheck,
                            size: 16,
                            color: riskColor,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              rec,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF475569),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Action Buttons
          ElevatedButton(
            onPressed: _resetForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0E7772),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Take Another Assessment',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 12),

          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0E7772),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: const BorderSide(color: Color(0xFF0E7772)),
            ),
            child: const Text(
              'Back to Home',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E293B),
        ),
      ),
    );
  }

  Widget _buildRadioGroup({
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: options.map((option) {
          final isSelected = value == option;
          return Expanded(
            child: InkWell(
              onTap: () => onChanged(option),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF0E7772).withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.horizontal(
                    left: option == options.first
                        ? const Radius.circular(12)
                        : Radius.zero,
                    right: option == options.last
                        ? const Radius.circular(12)
                        : Radius.zero,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: isSelected
                          ? const Color(0xFF0E7772)
                          : Colors.grey.shade400,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      option,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isSelected
                            ? const Color(0xFF0E7772)
                            : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNumberInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isDecimal = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),
        style: const TextStyle(
          color: Colors.black, // Set text color to black
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        inputFormatters: [
          if (isDecimal)
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
          else
            FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
          prefixIcon: FaIcon(icon, size: 18, color: const Color(0xFF0E7772)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required List<String> displayNames,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dropdownMenuTheme: DropdownMenuThemeData(
            inputDecorationTheme: InputDecorationTheme(
              fillColor: Colors.white,
              filled: true,
            ),
          ),
        ),
        child: DropdownButtonFormField<String>(
          value: value,
          dropdownColor: Colors.white,
          style: const TextStyle(
            color: Color(0xFF1E293B), // Dark text color for selected item
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
            prefixIcon: FaIcon(icon, size: 18, color: const Color(0xFF0E7772)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          items: List.generate(
            items.length,
            (index) => DropdownMenuItem(
              value: items[index],
              child: Text(
                displayNames[index],
                style: const TextStyle(
                  color: Color(
                    0xFF1E293B,
                  ), // Dark text color for dropdown items
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          onChanged: onChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select an option';
            }
            return null;
          },
          menuMaxHeight: 300, // Limit dropdown height
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF0E7772)),
        ),
      ),
    );
  }
}
