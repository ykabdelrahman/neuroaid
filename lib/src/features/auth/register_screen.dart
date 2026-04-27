import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:neuroaid/src/core/bloc/auth/auth_cubit.dart';
import 'package:neuroaid/src/core/bloc/auth/auth_state.dart';
import 'package:neuroaid/src/core/theme/app_colors.dart';
import 'package:neuroaid/src/core/utils/validators.dart';
import 'package:neuroaid/src/shared/widgets/app_text_field.dart';
import 'package:neuroaid/src/shared/widgets/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _dobController = TextEditingController();
  final _countryController = TextEditingController();
  final _addressController = TextEditingController();

  bool _obscurePassword = true;
  String? _selectedGender;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _dobController.dispose();
    _countryController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _handleRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedGender == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select your gender'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.danger,
          ),
        );
        return;
      }

      final fullName =
          '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';
      context.read<AuthCubit>().register(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: fullName,
        phone: _phoneController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Welcome, ${state.user.name}! Account created successfully.',
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context);
        } else if (state is AuthError) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Registration Failed'),
              content: Text(
                'Error: ${state.message}\n\nPlease check:\n1. Server is running (npm start)\n2. Phone is connected via USB\n3. ADB Reverse is active',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text(
              'Register',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),

                    // Logo
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/Logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // First Name
                    AppTextField(
                      hint: 'Example',
                      label: 'First Name*',
                      controller: _firstNameController,
                      validator: Validators.name,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),

                    // Last Name
                    AppTextField(
                      hint: 'Example',
                      label: 'Last Name*',
                      controller: _lastNameController,
                      validator: Validators.name,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),

                    // Email
                    AppTextField(
                      hint: 'example@gmail.com',
                      label: 'Email*',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),

                    // Password
                    AppTextField(
                      hint: 'Input password',
                      label: 'Password*',
                      controller: _passwordController,
                      obscure: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                      validator: Validators.password,
                      textInputAction: TextInputAction.next,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),

                    // Date of Birth
                    GestureDetector(
                      onTap: _selectDate,
                      child: AbsorbPointer(
                        child: AppTextField(
                          hint: 'Select date',
                          label: 'Data Of Birth*',
                          controller: _dobController,
                          suffixIcon: const Icon(
                            Icons.calendar_today_outlined,
                            color: AppColors.textSecondary,
                          ),
                          validator: Validators.date,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Gender Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                      ),
                      dropdownColor: AppColors.background,
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: AppColors.primary,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Gender*',
                        hintText: 'Choose your gender',
                        hintStyle: TextStyle(
                          color: AppColors.textSecondary.withOpacity(0.7),
                          fontSize: 16,
                        ),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.border,
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.border,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      items: ['Male', 'Female', 'Other'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedGender = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Mobile Phone
                    AppTextField(
                      hint: 'Enter your phone number',
                      label: 'Mobile Phone*',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      validator: Validators.phone,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(11),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Country
                    AppTextField(
                      hint: 'Country',
                      label: 'Your Country',
                      controller: _countryController,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),

                    // Address
                    AppTextField(
                      hint: 'Input full address',
                      label: 'Address',
                      controller: _addressController,
                      textInputAction: TextInputAction.done,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 30),

                    // Register Button
                    PrimaryButton(
                      label: isLoading ? 'Creating Account...' : 'Register',
                      onPressed: isLoading ? () {} : _handleRegister,
                    ),
                    const SizedBox(height: 24),

                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have account? ',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text(
                            'Sign In',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
