import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/app_text_field.dart';

class ServerConfigScreen extends StatefulWidget {
  const ServerConfigScreen({super.key});

  @override
  State<ServerConfigScreen> createState() => _ServerConfigScreenState();
}

class _ServerConfigScreenState extends State<ServerConfigScreen> {
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _loadSavedConfig();
  }

  Future<void> _loadSavedConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIp = prefs.getString('server_ip');
    final savedPort = prefs.getInt('server_port');

    if (savedIp != null) {
      _ipController.text = savedIp;
    } else {
      // Pre-fill with current network IP as a helpful default
      _ipController.text = '192.168.62.47';
    }

    if (savedPort != null) {
      _portController.text = savedPort.toString();
    } else {
      _portController.text = '8080'; // Default port
    }
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final ip = _ipController.text.trim();
    final portText = _portController.text.trim();

    // Validate inputs
    if (ip.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter server IP address';
        _isLoading = false;
      });
      return;
    }

    if (portText.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter port number';
        _isLoading = false;
      });
      return;
    }

    final port = int.tryParse(portText);
    if (port == null || port < 1 || port > 65535) {
      setState(() {
        _errorMessage = 'Invalid port number (must be 1-65535)';
        _isLoading = false;
      });
      return;
    }

    // Test connection
    try {
      final testUrl = 'http://$ip:$port';
      final isConnected = await ApiConstants.testConnection(testUrl);

      if (isConnected) {
        // Save configuration
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('server_ip', ip);
        await prefs.setInt('server_port', port);

        // Update ApiConstants
        ApiConstants.setCustomUrl(testUrl);

        // Update ApiService baseUrl immediately
        final apiService = GetIt.instance<ApiService>();
        apiService.updateBaseUrl(testUrl);

        setState(() {
          _successMessage = 'Connected successfully!';
          _isLoading = false;
        });

        // Navigate to app flow after short delay
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) {
          // After successful config, go to splash which will handle onboarding/auth
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/onboarding',
            (route) => false, // Remove all previous routes
          );
        }
      } else {
        setState(() {
          _errorMessage =
              'Cannot connect to server. Please check IP and ensure backend is running.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Connection failed: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _skipConfiguration() async {
    // Use default network IP temporarily
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('skip_server_config', true);

    // Set default IP for this session (use current network IP from constants)
    ApiConstants.useNetworkUrl();

    // Update ApiService baseUrl immediately
    final apiService = GetIt.instance<ApiService>();
    apiService.updateBaseUrl(ApiConstants.baseUrl);

    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/onboarding',
        (route) => false, // Remove all previous routes
      );
    }
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // Logo/Icon
              Container(
                height: 80,
                width: 80,
                alignment: Alignment.center,
                child: Icon(
                  Icons.settings_input_antenna,
                  size: 70,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 20),

              // Title
              Text(
                'Server Configuration',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Subtitle
              Text(
                'Enter your backend server details to connect',
                style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Instructions Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'How to find your server IP:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInstructionText(
                      '1. Start the backend server on your laptop',
                    ),
                    _buildInstructionText(
                      '2. Look for the IP address in the terminal output',
                    ),
                    _buildInstructionText(
                      '3. Example: 192.168.1.6 or 192.168.0.100',
                    ),
                    _buildInstructionText(
                      '4. Make sure both devices are on the same WiFi',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // IP Address Input
              AppTextField(
                controller: _ipController,
                hint: '192.168.1.6',
                label: 'Server IP Address',
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                prefixIcon: Icon(Icons.computer, color: AppColors.primary),
                enabled: !_isLoading,
              ),

              const SizedBox(height: 16),

              // Port Input
              AppTextField(
                controller: _portController,
                hint: '8080',
                label: 'Port',
                keyboardType: TextInputType.number,
                prefixIcon: Icon(
                  Icons.settings_ethernet,
                  color: AppColors.primary,
                ),
                enabled: !_isLoading,
              ),

              const SizedBox(height: 24),

              // Error Message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.danger),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: AppColors.danger,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: AppColors.danger,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Success Message
              if (_successMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.success),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: AppColors.success,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _successMessage!,
                          style: TextStyle(
                            color: AppColors.success,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Test Connection Button
              _isLoading
                  ? Container(
                      height: 54,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: AppColors.primary.withOpacity(0.6),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Testing Connection...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : PrimaryButton(
                      onPressed: _testConnection,
                      label: 'Test & Connect',
                    ),

              const SizedBox(height: 16),

              // Skip Button
              TextButton(
                onPressed: _isLoading ? null : _skipConfiguration,
                child: Text(
                  'Skip (Use Default Configuration)',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
      ),
    );
  }
}
